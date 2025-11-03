#!/usr/bin/env bash
set -euo pipefail

# --- Paramètres ---
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

# Emplacements de travail temporaires
TMP_DIR="$(mktemp -d)"
IMG_PATH="${TMP_DIR}/os.img"      # chemin final .img (décompressé si besoin)
ARCHIVE_PATH="${TMP_DIR}/os"      # sans extension ; on devinera .img.xz ou .img
trap 'rm -rf "${TMP_DIR}"; umount /mnt/boot 2>/dev/null || true; umount /mnt/root 2>/dev/null || true' EXIT

echo "[*] Paramètres:"
echo "    IMAGE_URL=${IMAGE_URL:-<non défini>}"
echo "    IMAGE=${IMAGE:-<non défini>}"
echo "    OUT=${OUT}"
echo "    MAKE_TARBALL=${MAKE_TARBALL}"

# --- Récupération de l'image ---
download_and_prepare_image() {
  local url="$1"
  test -n "$url" || return 1

  echo "[*] Téléchargement depuis URL : $url"
  # Télécharge dans ${ARCHIVE_PATH}.(img|img.xz)
  local guessed_ext=".bin"
  if [[ "$url" =~ \.img\.xz$ ]]; then
    guessed_ext=".img.xz"
  elif [[ "$url" =~ \.img$ ]]; then
    guessed_ext=".img"
  fi
  local dst="${ARCHIVE_PATH}${guessed_ext}"

  curl -L --fail --progress-bar -o "${dst}" "$url"

  # Vérification SHA256 si fournie
  if [[ -n "$IMAGE_SHA256" ]]; then
    echo "[*] Vérification SHA256…"
    echo "${IMAGE_SHA256}  ${dst}" | sha256sum -c -
  fi

  # Si .img.xz -> décompression flux direct vers IMG_PATH
  if [[ "$dst" =~ \.img\.xz$ ]]; then
    echo "[*] Décompression .img.xz -> ${IMG_PATH} (multi-threads si possible)"
    xz -T0 -dc "${dst}" > "${IMG_PATH}"
  else
    echo "[*] Fichier .img détecté -> copie"
    cp -a "${dst}" "${IMG_PATH}"
  fi
}

if [[ -n "$IMAGE_URL" ]]; then
  download_and_prepare_image "$IMAGE_URL"
elif [[ -n "$IMAGE" ]]; then
  echo "[*] Utilisation d'une image locale : $IMAGE"
  test -f "$IMAGE" || { echo "Image introuvable: $IMAGE"; exit 1; }
  # Détecter si .img.xz
  if file -b "$IMAGE" | grep -qi 'xz compressed'; then
    echo "[*] Décompression locale .img.xz -> ${IMG_PATH}"
    xz -T0 -dc "$IMAGE" > "${IMG_PATH}"
  else
    echo "[*] Copie locale .img -> ${IMG_PATH}"
    cp -a "$IMAGE" "${IMG_PATH}"
  fi
else
  echo "Erreur: ni IMAGE_URL ni IMAGE n'est défini."
  exit 1
fi

# --- Montage partitions & extraction ---
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

# Hypothèse standard Raspberry Pi OS : p1 = boot (FAT), p2 = root (ext4)
BOOT_PART="${LOOPDEV}p1"
ROOT_PART="${LOOPDEV}p2"

# Validation basique des partitions
if ! lsblk -no FSTYPE "${ROOT_PART}" | grep -q 'ext'; then
  echo "Attention: ${ROOT_PART} n'est pas ext*. Vérifie le partitionnement."
fi

# Montage en lecture seule
echo "[*] Montage des partitions (ro)…"
mount -o ro "${ROOT_PART}" /mnt/root
mount -o ro "${BOOT_PART}" /mnt/boot 2>/dev/null || true  # FAT peut ne pas exister selon l’image

# Copie du rootfs + /boot dans le sysroot
echo "[*] Copie du rootfs -> ${OUT}"
mkdir -p "${OUT}"
rsync -aHAX --numeric-ids --delete /mnt/root/ "${OUT}/"

if mountpoint -q /mnt/boot; then
  echo "[*] Copie de /boot -> ${OUT}/boot"
  mkdir -p "${OUT}/boot"
  rsync -aHAX --numeric-ids --delete /mnt/boot/ "${OUT}/boot/"
fi

# Normalisation des liens symboliques absolus en relatifs
echo "[*] Normalisation des liens symboliques absolus…"
find "${OUT}" -type l -print0 | while IFS= read -r -d '' link; do
  target="$(readlink "$link")" || continue
  if [[ "$target" = /* ]]; then
    rel="${target#/}"
    ln -snf "$rel" "$link"
  fi
done

# Tarball optionnel
if [[ "${MAKE_TARBALL}" = "1" ]]; then
  echo "[*] Création de l’archive /output/rpi2-sysroot.tar.gz"
  tar -C "${OUT}" -czf /output/rpi2-sysroot.tar.gz .
fi

echo "[*] Terminé. Sysroot disponible dans : ${OUT}"
