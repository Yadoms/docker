#!/usr/bin/env bash
set -euo pipefail

# --- Paramètres utilisateur ---
# IMAGE_URL : URL d’une image .img ou .img.xz (ex : Raspberry Pi OS officiel)
# IMAGE     : chemin d’une image locale déjà présente (si tu ne veux pas télécharger)
# OUT       : dossier sysroot cible dans le conteneur
# MAKE_TARBALL : 1 pour produire un tar.gz dans /output, 0 sinon
# IMAGE_SHA256 : (optionnel) checksum attendu de l’archive téléchargée (fichier ou valeur)
IMAGE_URL="${IMAGE_URL:-}"
IMAGE="${IMAGE:-}"
OUT="${OUT:-/sysroot}"
MAKE_TARBALL="${MAKE_TARBALL:-1}"
IMAGE_SHA256="${IMAGE_SHA256:-}"

# Réduction / optimisation
# MODE         : full (pas de réduction du sysroot), minimal (sysroot minimaliste par whitelist)
# PRUNE        : nettoyer le ssyroot après copie en mode full
# KEEP_LOCALES : locales à conserver si PRUNE=1
# STRIP        : 1 pour strip (suppression des symboles et infos de debug) des .so/bin (gros gain)
MODE="${MODE:-full}"          # full | minimal
PRUNE="${PRUNE:-0}"           # 1 pour nettoyer après copie en mode full
KEEP_LOCALES="${KEEP_LOCALES:-en fr}"  # locales à conserver si PRUNE=1
STRIP="${STRIP:-0}"           # 1 pour strip des .so/bin (gros gain)

# --- Dossiers temporaires ---
TMP_DIR="$(mktemp -d)"
IMG_PATH="${TMP_DIR}/os.img"
ARCHIVE_PATH="${TMP_DIR}/os"
trap 'rm -rf "${TMP_DIR}"; umount /mnt/boot 2>/dev/null || true; umount /mnt/root 2>/dev/null || true' EXIT

echo "[*] Paramètres:"
echo "    IMAGE_URL=${IMAGE_URL:-<non défini>}"
echo "    IMAGE=${IMAGE:-<non défini>}"
echo "    OUT=${OUT}"
echo "    MAKE_TARBALL=${MAKE_TARBALL}"
echo "    MODE=${MODE} (minimal = whitelist, full = copie complète)"
echo "    PRUNE=${PRUNE} (actif seulement en MODE=full)"
echo "    KEEP_LOCALES=${KEEP_LOCALES}"
echo "    STRIP=${STRIP}"

download_and_prepare_image() {
  local url="$1"
  test -n "$url" || return 1

  echo "[*] Téléchargement depuis URL : $url"
  local guessed_ext=".bin"
  if [[ "$url" =~ \.img\.xz$ ]]; then
    guessed_ext=".img.xz"
  elif [[ "$url" =~ \.img$ ]]; then
    guessed_ext=".img"
  fi
  local dst="${ARCHIVE_PATH}${guessed_ext}"
  curl -L --fail --progress-bar -o "${dst}" "$url"

  if [[ -n "$IMAGE_SHA256" ]]; then
    echo "[*] Vérification SHA256…"
    echo "${IMAGE_SHA256}  ${dst}" | sha256sum -c -
  fi
  if [[ "$dst" =~ \.img\.xz$ ]]; then
    echo "[*] Décompression .img.xz -> ${IMG_PATH}"
    xz -T0 -dc "${dst}" > "${IMG_PATH}"
  else
    cp -a "${dst}" "${IMG_PATH}"
  fi
}

if [[ -n "$IMAGE_URL" ]]; then
  download_and_prepare_image "$IMAGE_URL"
elif [[ -n "$IMAGE" ]]; then
  echo "[*] Image locale : $IMAGE"
  test -f "$IMAGE" || { echo "Image introuvable: $IMAGE"; exit 1; }
  if file -b "$IMAGE" | grep -qi 'xz compressed'; then
    echo "[*] Décompression locale .img.xz -> ${IMG_PATH}"
    xz -T0 -dc "$IMAGE" > "${IMG_PATH}"
  else
    cp -a "$IMAGE" "${IMG_PATH}"
  fi
else
  echo "Erreur: ni IMAGE_URL ni IMAGE n'est défini."
  exit 1
fi

# --- Loop / partitions (robuste: loopXp?, kpartx, offset) ---
echo "[*] Attache l'image en loop et scanne les partitions…"
LOOPDEV="$(losetup -f --show -P "${IMG_PATH}")"
cleanup_loop() {
  sync || true
  umount /mnt/boot 2>/dev/null || true
  umount /mnt/root 2>/dev/null || true
  kpartx -d "${LOOPDEV}" 2>/dev/null || true
  losetup -d "${LOOPDEV}" 2>/dev/null || true
}
trap 'cleanup_loop; rm -rf "${TMP_DIR}"' EXIT

echo "[*] Loop device: ${LOOPDEV}"
lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT "${LOOPDEV}" || true

BOOT_PART=""
ROOT_PART=""
if [[ -b "${LOOPDEV}p1" && -b "${LOOPDEV}p2" ]]; then
  BOOT_PART="${LOOPDEV}p1"
  ROOT_PART="${LOOPDEV}p2"
else
  echo "[*] Création des mappages de partition via kpartx…"
  kpartx -as "${LOOPDEV}" || kpartx -av "${LOOPDEV}"
  base="$(basename "${LOOPDEV}")"
  if [[ -b "/dev/mapper/${base}p1" && -b "/dev/mapper/${base}p2" ]]; then
    BOOT_PART="/dev/mapper/${base}p1"
    ROOT_PART="/dev/mapper/${base}p2"
  fi
fi

mount_by_offset() {
  local dev="$1" partnum="$2" mnt="$3" fstype_hint="$4"
  local start
  # Essais multiples selon le format de fdisk
  start="$(fdisk -l "$dev" | awk -v p="$partnum" '$0 ~ " "p" " && $2 ~ /^[0-9]+$/ {print $2; exit}')"
  if [[ -z "$start" ]]; then
    start="$(fdisk -l "$dev" | awk -v p="$partnum" '$0 ~ "^"dev"p"p {print $2; exit}' dev="$dev")"
  fi
  test -n "$start" || { echo "Impossible de déterminer l'offset pour ${dev} part ${partnum}"; return 1; }
  local offset=$(( start * 512 ))
  echo "[*] Montage par offset (part${partnum}) offset=${offset}"
  mkdir -p "$mnt"
  if [[ -n "$fstype_hint" ]]; then
    mount -o ro,offset="$offset" -t "$fstype_hint" "$dev" "$mnt"
  else
    mount -o ro,offset="$offset" "$dev" "$mnt"
  fi
}

echo "[*] Résolution des partitions:"
echo "    BOOT_PART=${BOOT_PART:-<offset>}"
echo "    ROOT_PART=${ROOT_PART:-<offset>}"

mkdir -p /mnt/root /mnt/boot
echo "[*] Montage des partitions (ro)…"
if [[ -n "${ROOT_PART}" && -b "${ROOT_PART}" ]]; then
  mount -o ro "${ROOT_PART}" /mnt/root
else
  mount_by_offset "${LOOPDEV}" 2 /mnt/root ext4
fi
if [[ -n "${BOOT_PART}" && -b "${BOOT_PART}" ]]; then
  mount -o ro "${BOOT_PART}" /mnt/boot || true
else
  mount_by_offset "${LOOPDEV}" 1 /mnt/boot "" || true
fi

# ===========================================
#  Préparation des répertoires de sortie
# ===========================================
echo "[*] Préparation des répertoires de sortie"

if [[ -d "${OUT}" ]]; then
  echo "    Nettoyage du contenu existant dans ${OUT}"
  rm -rf "${OUT:?}/"* || true
else
  echo "    Création du répertoire ${OUT}"
  mkdir -p "${OUT}"
fi

if [[ -d "/output" ]]; then
  echo "    Nettoyage du contenu existant dans /output"
  rm -rf /output/* || true
else
  echo "    Création du répertoire /output"
  mkdir -p /output
fi

# ===========================================
#  Fichiers include/exclude pour rsync
# ===========================================
RSYNC_INC="${TMP_DIR}/rsync-include.txt"
RSYNC_EXC="${TMP_DIR}/rsync-exclude.txt"

# Whitelist pour MODE=minimal (libs/headers/pkg-config/ssl/ld conf)
cat >"$RSYNC_INC" <<'PATTERNS'
+ /lib/
+ /lib/***
+ /lib/arm-linux-gnueabihf/
+ /lib/arm-linux-gnueabihf/***
+ /usr/
+ /usr/include/
+ /usr/include/***
+ /usr/local/include/
+ /usr/local/include/***
+ /usr/lib/
+ /usr/lib/***
+ /usr/local/lib/
+ /usr/local/lib/***
+ /usr/lib/arm-linux-gnueabihf/
+ /usr/lib/arm-linux-gnueabihf/***
+ /usr/lib/pkgconfig/
+ /usr/lib/pkgconfig/***
+ /usr/lib/arm-linux-gnueabihf/pkgconfig/
+ /usr/lib/arm-linux-gnueabihf/pkgconfig/***
+ /usr/share/pkgconfig/
+ /usr/share/pkgconfig/***
+ /etc/
+ /etc/ld.so.conf
+ /etc/ld.so.conf.d/
+ /etc/ld.so.conf.d/***
+ /etc/ssl/
+ /etc/ssl/***
+ /etc/alternatives/
+ /etc/alternatives/***
+ /opt/
+ /opt/vc/
+ /opt/vc/***
- ***
PATTERNS

# Exclusions "en dur" pour environnement headless (sans GUI)
cat >"$RSYNC_EXC" <<'EXCLUDES'
# === Navigateurs et gros clients ===
- /usr/lib/chromium/***
- /usr/lib/chromium-browser/***
- /usr/lib/firefox/***

# === Stack graphique: X11 / Wayland / GL / GPU ===
- /usr/lib/xorg/***
- /usr/lib/X11/***
- /usr/lib/arm-linux-gnueabihf/dri/***
- /usr/lib/arm-linux-gnueabihf/libEGL***
- /usr/lib/arm-linux-gnueabihf/libGLES***
- /usr/lib/arm-linux-gnueabihf/libGL***
- /usr/lib/arm-linux-gnueabihf/libOpenGL***
- /usr/lib/arm-linux-gnueabihf/libopengl***
- /usr/lib/arm-linux-gnueabihf/libGLX***
- /usr/lib/arm-linux-gnueabihf/libxkbcommon***
- /usr/lib/arm-linux-gnueabihf/libX***
- /usr/lib/arm-linux-gnueabihf/libxcb***
- /usr/lib/arm-linux-gnueabihf/libwayland***
- /usr/lib/arm-linux-gnueabihf/libdrm***
- /usr/lib/arm-linux-gnueabihf/libvulkan***
- /usr/lib/arm-linux-gnueabihf/libgbm***

# === Toolkits GUI : GTK/Qt/SDL/Cairo/Pango/etc. ===
- /usr/lib/arm-linux-gnueabihf/libgdk***
- /usr/lib/arm-linux-gnueabihf/libgtk***
- /usr/lib/arm-linux-gnueabihf/libQt5***
- /usr/lib/arm-linux-gnueabihf/libqt5***
- /usr/lib/arm-linux-gnueabihf/libQt6***
- /usr/lib/arm-linux-gnueabihf/libqt6***
- /usr/lib/arm-linux-gnueabihf/libSDL***
- /usr/lib/arm-linux-gnueabihf/libSDL2***
- /usr/lib/arm-linux-gnueabihf/libcairo***
- /usr/lib/arm-linux-gnueabihf/libpango***
- /usr/lib/arm-linux-gnueabihf/libatk***
- /usr/lib/arm-linux-gnueabihf/libgdk_pixbuf***
- /usr/lib/arm-linux-gnueabihf/libfontconfig***
- /usr/lib/arm-linux-gnueabihf/libfreetype***
- /usr/lib/arm-linux-gnueabihf/libharfbuzz***
- /usr/lib/arm-linux-gnueabihf/libpixman***
- /usr/lib/arm-linux-gnueabihf/libfribidi***
- /usr/lib/arm-linux-gnueabihf/libEGL_mesa***
- /usr/lib/arm-linux-gnueabihf/libGLX_mesa***

# === Ressources GUI / thèmes / icônes / polices ===
- /usr/share/X11/***
- /usr/share/icons/***
- /usr/share/fonts/***
- /usr/share/themes/***
- /usr/share/gtk-3.0/***
- /usr/share/gtk-4.0/***
- /usr/share/wayland/***
- /usr/share/applications/***
- /usr/share/mime/***
- /usr/share/glvnd/***
- /usr/share/drirc.d/***
- /usr/share/gdm/***
- /usr/share/lightdm/***
- /usr/share/gnome/***
- /usr/share/kde4/***
- /usr/share/kf5/***
- /usr/share/qt5/***
- /usr/share/qt6/***
- /usr/share/pixmaps/***
- /usr/share/backgrounds/***

# === GPU / firmware graphique / noyau ===
- /lib/modules/***
- /lib/firmware/***
- /opt/vc/src/***
- /opt/vc/lib/libEGL***
- /opt/vc/lib/libGLES***
- /opt/vc/lib/libGL***
- /opt/vc/lib/libvcos***
- /opt/vc/lib/libvchiq***
- /opt/vc/lib/libopenmaxil***

# === Divers lourds non critiques pour la compilation ===
- /usr/lib/llvm-*/
- /usr/lib/debug/***
- /usr/share/doc/***
- /usr/share/man/***
# locales très volumineuses (adapter si besoin)
- /usr/share/locale/zh_CN/***
- /usr/share/locale/ja/***
- /usr/share/locale/ru/***
- /usr/share/locale/de/***
EXCLUDES

# ===========================================
#  Copie du sysroot (avec exclusions)
# ===========================================
copy_minimal() {
  echo "[*] MODE=minimal : copie whitelist + exclusions GUI…"
  rsync -aHAX --numeric-ids --delete \
    --include-from="$RSYNC_INC" \
    --exclude-from="$RSYNC_EXC" \
    /mnt/root/ "${OUT}/"
}

copy_full() {
  echo "[*] MODE=full : copie complète du rootfs…"
  rsync -aHAX --numeric-ids --delete /mnt/root/ "${OUT}/"
  if mountpoint -q /mnt/boot; then
    mkdir -p "${OUT}/boot"
    rsync -aHAX --numeric-ids --delete /mnt/boot/ "${OUT}/boot/"
  fi
}

if [[ "$MODE" = "minimal" ]]; then
  copy_minimal
else
  copy_full
fi

# --- Nettoyage / réduction (PRUNE) pour MODE=full ---
prune_full() {
  echo "[*] PRUNE: allègement du sysroot…"
  # 1) docs & pages de man
  rm -rf "${OUT}/usr/share/doc" "${OUT}/usr/share/info" "${OUT}/usr/share/man" || true

  # 2) locales (ne garde que celles spécifiées)
  if [[ -d "${OUT}/usr/share/locale" ]]; then
    find "${OUT}/usr/share/locale" -mindepth 1 -maxdepth 1 -type d \
      | while read -r d; do
          keep=0
          for l in ${KEEP_LOCALES}; do
            [[ "$(basename "$d")" == "$l"* ]] && keep=1
          done
          [[ $keep -eq 1 ]] || rm -rf "$d"
        done
  fi

  # 3) caches, logs, APT
  rm -rf "${OUT}/var/cache/apt/"* "${OUT}/var/lib/apt/lists/"* "${OUT}/var/log/"* || true
  rm -rf "${OUT}/var/cache/"* || true

  # 4) kernel & firmware (non nécessaires à la compilation)
  rm -rf "${OUT}/lib/modules" "${OUT}/lib/firmware" "${OUT}/boot" || true

  # 5) dev inutiles (on garde /usr/include !)
  rm -rf "${OUT}/usr/src" || true

  # 6) binaires du target (souvent inutiles côté sysroot)
  rm -rf "${OUT}/bin" "${OUT}/sbin" "${OUT}/usr/sbin" || true
  # (on garde /usr/bin par prudence, certains .pc/scripts peuvent y référer)
}

if [[ "$MODE" = "full" && "$PRUNE" = "1" ]]; then
  prune_full
fi

# ===========================================
#  STRIP (avec logs détaillés, fix $1, PIE, strip cible)
# ===========================================
if [[ "$STRIP" = "1" ]]; then
  echo "[*] STRIP: réduction des binaires/so…"

  # Choisir le meilleur outil de strip disponible (cible > hôte)
  if command -v arm-linux-gnueabihf-strip >/dev/null 2>&1; then
    STRIP_CMD="arm-linux-gnueabihf-strip"
  else
    STRIP_CMD="strip"
  fi
  echo "    Utilitaire: ${STRIP_CMD}"

  strip_file() {
    local f="$1"
    # Ignore si pas un fichier régulier
    [[ -f "$f" ]] || return 0

    # Déterminer type: d’abord ELF avec 'readelf' (plus fiable), puis MIME
    if readelf -h "$f" >/dev/null 2>&1; then
      # ELF: décider du mode de strip
      if [[ "$f" =~ \.so(\.|$) || "$f" =~ \.so[0-9]*$ ]]; then
        echo "    [strip-debug] $f"
        "$STRIP_CMD" --strip-debug "$f" 2>/dev/null || true
      else
        # exécutable ELF/PIE
        echo "    [strip-all]   $f"
        "$STRIP_CMD" --strip-all "$f" 2>/dev/null || true
      fi
      return 0
    fi

    # Si ce n’est pas un ELF, regarder les archives .a
    local mime
    mime=$(file -b --mime-type "$f" 2>/dev/null || echo "")
    case "$mime" in
      application/x-archive)
        echo "    [strip-archive] $f"
        "$STRIP_CMD" --strip-debug "$f" 2>/dev/null || true
        return 0
        ;;
      application/x-executable|application/x-pie-executable|application/x-sharedlib)
        # On ne devrait pas arriver ici si readelf détecte l’ELF, mais au cas où :
        echo "    [strip-elf]     $f"
        "$STRIP_CMD" --strip-debug "$f" 2>/dev/null || true
        return 0
        ;;
      *) ;;
    esac

    # Sinon : ignorer silencieusement (scripts, textes, linker scripts .so “texte”, etc.)
    return 0
  }

  export STRIP_CMD
  export -f strip_file

  echo "[*] Analyse dans ${OUT}…"
  # ⚠️ Bien passer le chemin en $1 (et non $0) + fixer $0 à '_'
  find "${OUT}" -type f -perm -111 -print0 \
    | xargs -0 -I{} bash -c 'strip_file "$1"' _ {}

  # Les bibliothèques .so ne sont pas toujours exécutables : passer un second balayage
  find "${OUT}" -type f -name "*.so*" -print0 \
    | xargs -0 -I{} bash -c 'strip_file "$1"' _ {}

  # Bibliothèques statiques & libtool : supprimer, avec trace
  find "${OUT}" -type f \( -name "*.a" -o -name "*.la" \) -print -delete \
    | sed 's/^/    [delete-static] /'

  echo "[*] STRIP terminé."
fi




# --- Normalisation des liens symboliques absolus ---
echo "[*] Normalisation des symlinks absolus -> relatifs…"
find "${OUT}" -type l -print0 | while IFS= read -r -d '' link; do
  target="$(readlink "$link")" || continue
  if [[ "$target" = /* ]]; then
    ln -snf "${target#/}" "$link"
  fi
done

# --- Archive optionnelle ---
if [[ "${MAKE_TARBALL}" = "1" ]]; then
  echo "[*] Création de l’archive /output/rpi2-sysroot.tar.gz"
  tar -C "${OUT}" -czf /output/rpi2-sysroot.tar.gz .
fi

echo "[*] Terminé. Sysroot : ${OUT}"
