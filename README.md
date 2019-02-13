# Fil'Harmonic Infrastructure

Ce projet contient des scripts et la configuration de l'infrastructure déployée pour héberger [filharmonic.beta.gouv.fr](https://filharmonic.beta.gouv.fr).

L'idée est d'installer le moins de paquets possibles sur le serveur et d'utiliser des conteneurs Docker pour faire tourner tous les services.


## Arborescence

- modules/ : contient un répertoire par service déployé
- modules/filharmonic : contient la stack Fil'Harmonic : [UI](https://github.com/MTES-MCT/filharmonic-ui), [API](https://github.com/MTES-MCT/filharmonic-api), bases de données
- modules/traefik : reverse proxy et TLS automatique avec Let's Encrypt
- playbooks/
  - deploy.yml : playbook ansible utilisé pour mettre à jour le serveur


## Prérequis serveur

- Debian 9
- rsync (installé manuellement)


## Configuration CircleCI

Dans CircleCI :
- Créer le projet filharmonic-infrastructure
- Ajouter les variables d'environnement (via Settings > Environment Variables) :
  - SERVER_FINGERPRINT
  - SSH_PRIVATE_KEY_BASE64


## Exécution de commandes one-shot

Il arrive parfois de devoir faire des actions une seule fois, comme une migration ou un import de données.
Il n'y a rien de prévu pour ces cas-là, et il faut alors effectuer l'action manuellement en se connectant en SSH car aucun service n'est directement exposé sur internet.


### Exemple d'import de la base de données S3IC

```sh
scp s3ic_ic_gen_fabnum.csv root@filharmonic.beta.gouv.fr:/tmp/
ssh root@filharmonic.beta.gouv.fr docker-compose -f /srv/config/filharmonic/docker-compose.yml run --rm -v "/tmp/s3ic_ic_gen_fabnum.csv:/data.csv:ro" api filharmonic-api -import-etablissements /data.csv
ssh root@filharmonic.beta.gouv.fr rm -f /tmp/s3ic_ic_gen_fabnum.csv
```
