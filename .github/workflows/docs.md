### Cluster-apply.yaml :

1. **Terraform Plan Job (`terraform_plan`)**:
   - Ce job exécute `terraform plan` et sauvegarde le résultat dans un fichier `tfplan`.
   - Si `terraform plan` réussit (c'est-à-dire sans erreurs), il enregistre l'artifact `tfplan`.

2. **Terraform Apply Job (`terraform_apply`)**:
   - Ce job est conditionné par la réussite du job `terraform_plan` grâce à `needs: terraform_plan`.
   - Il télécharge l'artifact `tfplan` généré par `terraform_plan`.
   - Il configure Terraform et AWS comme dans le premier job.
   - Il exécute `terraform apply` en utilisant le plan précédemment généré (`tfplan`).

### Conditions d'exécution :
- Le job `terraform_apply` utilise `if: success()` pour s'assurer qu'il ne s'exécute que si le job précédent (`terraform_plan`) s'est terminé avec succès (c'est-à-dire sans erreurs).

Avec cette configuration, `terraform apply` ne sera déclenché que si `terraform plan` s'exécute correctement sans erreurs, assurant ainsi une gestion prudente des changements d'infrastructure avec Terraform dans votre pipeline GitHub Actions.

### Cluster-destroy.yaml :

1. **Déclenchement du Workflow** (`on: workflow_dispatch`):
   - Le workflow est déclenché manuellement via l'interface GitHub Actions.

2. **Terraform Destroy Job** (`terraform_destroy`):
   - Utilise `ubuntu-latest` comme environnement d'exécution.
   - Comprend des étapes similaires au job de planification, à savoir le `checkout` du dépôt, la configuration de Terraform et des credentials AWS, suivie de l'initialisation de Terraform.
   - Finalement, il exécute `terraform destroy --auto-approve`, qui détruit les ressources Terraform sans demande d'approbation supplémentaire.

### Points à Noter :

- **AWS Credentials** : Assurez-vous que les variables `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` sont correctement configurées dans les secrets du dépôt GitHub. Elles doivent avoir les permissions nécessaires pour exécuter les opérations de destruction.

- **Sécurité** : Le `terraform destroy` supprime toutes les ressources gérées par votre configuration Terraform. Soyez prudent avec ce workflow et assurez-vous que l'exécution manuelle soit restreinte aux utilisateurs ayant les permissions appropriées pour éviter des suppressions involontaires.

- **Terraform Backend** : Le fichier `backend.hcl` est utilisé pour configurer le backend de Terraform. Assurez-vous que ce fichier est correctement configuré pour votre backend (par exemple, S3 pour AWS).

Ce workflow vous permet de détruire facilement les ressources gérées par Terraform avec un minimum d'interaction, ce qui est particulièrement utile pour les environnements de test ou lorsque vous devez rapidement nettoyer les ressources.