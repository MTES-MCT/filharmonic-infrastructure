# Fil'Harmonic Infrastructure

Ce projet contient les sources de l'infrastructure déployée pour héberger [filharmonic.beta.gouv.fr](https://filharmonic.beta.gouv.fr).
Elle se base sur [compose-deploy](https://github.com/totakoko/compose-deploy).


## Arborescence

- coredns : dns ayant autorité sur la zone filharmonic.beta.gouv.fr
- filharmonic : contient la stack Fil'Harmonic : [UI](https://github.com/MTES-MCT/filharmonic-ui), [API](https://github.com/MTES-MCT/filharmonic-api), bases de données
- filharmonic-demo : UI mockée ayant servi au début du projet
- mail : serveur mail qui gère les emails du domaine filharmonic.beta.gouv.fr
- traefik : reverse proxy et TLS automatique avec Let's Encrypt
- restic : sauvegardes quotidiennes des données de tous les services


## Configuration CircleCI

Dans CircleCI :
- Créer le projet filharmonic-infrastructure
- Ajouter les variables d'environnement (via Settings > Environment Variables) :
  - SSH_HOST
  - SSH_FINGERPRINT_BASE64
  - SSH_PRIVATE_KEY_BASE64
  - cd_filharmonic_api_FILHARMONIC_EMAILS_SMTPPASS
  - cd_mail_mailserver_DBPASS
  - cd_mail_mailserver_RSPAMD_PASSWORD
  - cd_mail_postfixadmin_DBPASS
  - cd_mail_postgres_POSTGRES_PASSWORD
  - cd_restic_restic_RESTIC_PASSWORD


## Exécution de commandes one-shot

Il arrive parfois de devoir faire des actions une seule fois, comme une migration ou un import de données.
Il n'y a rien de prévu pour ces cas-là, et il faut alors effectuer l'action manuellement en se connectant en SSH car aucun service n'est directement exposé sur internet.


### Import de la base de données S3IC

```sh
scp s3ic_ic_gen_fabnum.csv root@filharmonic.beta.gouv.fr:/tmp/
ssh root@filharmonic.beta.gouv.fr docker-compose -f /srv/config/filharmonic/docker-compose.yml run --rm -v "/tmp/s3ic_ic_gen_fabnum.csv:/data.csv:ro" api filharmonic-api -import-etablissements /data.csv
ssh root@filharmonic.beta.gouv.fr rm -f /tmp/s3ic_ic_gen_fabnum.csv
```


### Import des utilisateurs inspecteurs

Conversion temporaire, en attendant d'avoir un CSV propre (besoin des paquets iconv et csvtool) :
```sh
iconv -f ISO-8859-1 -t UTF-8 Liste_d_agents.csv >! inspecteurs_tab.csv
csvtool -t TAB -u \; cat inspecteurs_tab.csv >! inspecteurs.csv
go run main.go -import-inspecteurs inspecteurs.csv
```

```sh
scp inspecteurs.csv root@filharmonic.beta.gouv.fr:/tmp/
ssh root@filharmonic.beta.gouv.fr docker-compose -f /srv/config/filharmonic/docker-compose.yml run --rm -v "/tmp/inspecteurs.csv:/data.csv:ro" api filharmonic-api -import-inspecteurs /data.csv
ssh root@filharmonic.beta.gouv.fr rm -f /tmp/inspecteurs.csv
```

### Import des utilisateurs exploitants

```sh
scp exploitants.csv root@filharmonic.beta.gouv.fr:/tmp/
ssh root@filharmonic.beta.gouv.fr docker-compose -f /srv/config/filharmonic/docker-compose.yml run --rm -v "/tmp/exploitants.csv:/data.csv:ro" api filharmonic-api -import-exploitants /data.csv
ssh root@filharmonic.beta.gouv.fr rm -f /tmp/exploitants.csv
```

### Génération des statistiques

```sh
ssh root@filharmonic.beta.gouv.fr docker-compose -f /srv/config/filharmonic/docker-compose.yml run postgresql psql -U filharmonic -c "COPY ( select inspection.etablissement_id, point_de_controle.id as point_de_controle_id, constat.type as constat_type
from inspections as inspection
join point_de_controles as point_de_controle on point_de_controle.inspection_id = inspection.id
left join constats as constat on point_de_controle.constat_id = constat.id ) TO STDOUT WITH CSV HEADER" > /tmp/stats.csv
scp root@filharmonic.beta.gouv.fr:/tmp/stats.csv ~/
ssh root@filharmonic.beta.gouv.fr rm -f /tmp/stats.csv
```
