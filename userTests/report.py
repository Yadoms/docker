import pysftp

cnopts = pysftp.CnOpts()
cnopts.hostkeys = None  

with pysftp.Connection('ftp.jano42.fr', username='janofnxr-usertests', password='Usertests2019', cnopts=cnopts) as sftp:
    sftp.put('/report.html')
