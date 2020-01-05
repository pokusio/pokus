#  Multer Local Storage

Ici, `multer` devrait stocker les fichiers, pourvu que le paramètre de
formulaire `cheminFichierSousEdition` ait pour valeur le chemin
du sous-répertoire de `workspace/pokus`, dans lequel on veut enregistrer le fichier sur le serveur :

```bash
curl -L -X POST -F 'fichierSousEdition=@"./ptitestespace/autrefichier.pokus"'  -F 'cheminFichierSousEdition="./ptitestespace/"' http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/files/uploadFile
# pour l'instant, les fichiers sont tous enregistrés dansle sous-répertoire 'workspace/pokus/subfolder1'
```
