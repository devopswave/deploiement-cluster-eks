# Déploiement d'un Cluster EKS avec Terraform

Ce guide fournit des instructions détaillées pour déployer un cluster Amazon EKS (Elastic Kubernetes Service) sur AWS en utilisant Terraform. Il inclut la configuration d'un VPC, le déploiement du cluster EKS, et la configuration des groupes de nœuds.

## Table des Matières

- [Introduction](#introduction)
- [Prérequis](#prérequis)
- [Structure du Projet](#structure-du-projet)
- [Utilisation](#utilisation)
- [Configuration](#configuration)
- [Déploiement du Cluster](#déploiement-du-cluster)
- [Nettoyage](#nettoyage)
- [Détails de la Configuration Terraform](#détails-de-la-configuration-terraform)
- [Sorties](#sorties)
- [Notes](#notes)
- [Licence](#licence)
- [Remerciements](#remerciements)

## Introduction

Ce dépôt contient du code Terraform pour déployer un cluster EKS avec des groupes de nœuds managés sur AWS. La configuration comprend la création d'un VPC, le déploiement d'EKS, et la gestion des rôles et politiques IAM nécessaires.

## Prérequis

Assurez-vous d'avoir installé les éléments suivants :

- [Terraform](https://www.terraform.io/downloads.html) `~> 1.3`
- [AWS CLI](https://aws.amazon.com/cli/) et configuré avec les identifiants nécessaires.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) pour interagir avec le cluster Kubernetes.

## Structure du Projet

```bash
├── main.tf                # Configuration principale de Terraform
├── variables.tf           # Variables d'entrée
├── outputs.tf             # Valeurs de sortie
├── README.md              # Ce fichier
├── .gitignore             # Fichier .gitignore
```

## Utilisation

### Étape 1: Cloner le Dépôt

```sh
git clone https://github.com/votre-repo/deploiement-cluster-eks.git
cd deploiement-cluster-eks
```

### Étape 2: Configurer les Identifiants AWS

Configurez vos identifiants AWS en utilisant l'une des méthodes suivantes :

- **Variables d'environnement :**
  ```sh
  export AWS_ACCESS_KEY_ID=your_access_key
  export AWS_SECRET_ACCESS_KEY=your_secret_key
  ```
- **Configuration AWS CLI :**
  ```sh
  aws configure
  ```
- **Rôles IAM :** Si vous utilisez des instances EC2, assurez-vous que le profil de l'instance a les permissions nécessaires.

### Étape 3: Initialiser Terraform

```sh
terraform init
```

### Étape 4: Configurer les Variables

Créez un fichier `terraform.tfvars` pour remplacer les valeurs par défaut :
```hcl
region = "us-west-2"
project_name = "monprojet"
vpc_cidr = "10.1.0.0/16"
cidrs_public = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
cidrs_private = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
node_group_type = "AL2_x86_64"
node_instance_type = "t3.medium"
scaling_config = {
  "desired_size" = 2
  "max_size" = 5
  "min_size" = 1
}
```

### Étape 5: Planifier le Déploiement

```sh
terraform plan -out=tfplan
```

### Étape 6: Appliquer le Plan

```sh
terraform apply tfplan
```

### Étape 7: Configurer kubectl

Pour interagir avec votre cluster EKS en utilisant `kubectl`, mettez à jour votre kubeconfig :
```sh
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

### Étape 8: Vérifier le Déploiement

Vérifiez que votre cluster est opérationnel :
```sh
kubectl get nodes
```

## Configuration

### Variables d'Entrée

- **region** : Région AWS pour déployer les ressources.
- **project_name** : Préfixe de nom pour les ressources.
- **vpc_cidr** : Bloc CIDR pour le VPC.
- **cidrs_public** : Liste des blocs CIDR pour les sous-réseaux publics.
- **cidrs_private** : Liste des blocs CIDR pour les sous-réseaux privés.
- **node_group_type** : Type AMI du groupe de nœuds managés.
- **node_instance_type** : Type d'instance EC2 pour les nœuds.
- **scaling_config** : Tailles désirée, maximale et minimale pour les groupes de nœuds.

### Exemple de `terraform.tfvars`

```hcl
region = "us-west-2"
project_name = "exemple"
vpc_cidr = "10.0.0.0/16"
cidrs_public = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
cidrs_private = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
node_group_type = "AL2_x86_64"
node_instance_type = "t3.medium"
scaling_config = {
  "desired_size" = 3
  "max_size" = 6
  "min_size" = 2
}
```

## Déploiement du Cluster

1. **Initialiser Terraform :**
   ```sh
   terraform init
   ```

2. **Planifier le Déploiement :**
   ```sh
   terraform plan -out=tfplan
   ```

3. **Appliquer le Plan :**
   ```sh
   terraform apply tfplan
   ```

4. **Configurer kubectl :**
   ```sh
   aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
   ```

5. **Vérifier le Cluster :**
   ```sh
   kubectl get nodes
   ```

## Nettoyage

Pour détruire toutes les ressources créées par cette configuration :

```sh
terraform destroy
```

## Détails de la Configuration Terraform

### `main.tf`

Ce fichier inclut :
- La configuration du fournisseur AWS.
- La source de données pour les zones de disponibilité.
- Les valeurs locales pour les noms dynamiques.
- La création du VPC en utilisant le module VPC.
- Le déploiement d'EKS en utilisant le module EKS.
- Les rôles IAM et les politiques pour EKS et les groupes de nœuds.

### `variables.tf`

Définit les variables d'entrée avec des descriptions et des valeurs par défaut.

### `outputs.tf`

Définit les sorties pour fournir des informations sur le cluster déployé, y compris l'endpoint du cluster, l'ID du groupe de sécurité, et le nom du cluster.

### Modules

- **Module VPC :** Gère la création du VPC, des sous-réseaux, des passerelles NAT, et des composants réseau nécessaires.
- **Module EKS :** Gère la création du cluster EKS, des groupes de nœuds, et des rôles IAM et politiques nécessaires.

### Versions

Assurez-vous de la compatibilité des versions des fournisseurs et modules suivants :
- **Fournisseur AWS :** `~> 5.47.0`
- **Fournisseur Random :** `~> 3.6.1`
- **Fournisseur TLS :** `~> 4.0.5`
- **Fournisseur CloudInit :** `~> 2.3.4`
- **Module VPC :** `5.8.1`
- **Module EKS :** `20.8.5`

## Sorties

Les sorties suivantes sont disponibles après le déploiement :

| Nom                     | Description                                           |
|-------------------------|-------------------------------------------------------|
| `cluster_endpoint`      | Endpoint pour le plan de contrôle EKS                 |
| `cluster_security_group_id` | IDs du groupe de sécurité attachés au plan de contrôle du cluster |
| `region`                | Région AWS                                            |
| `cluster_name`          | Nom du cluster Kubernetes                             |

## Notes

- **Types d'Instances :** Assurez-vous que les types d'instances sélectionnés sont disponibles dans votre région spécifiée et répondent aux exigences de vos charges de travail.
- **Limites de Ressources :** Soyez conscient des limites de service AWS et assurez-vous que votre compte dispose des quotas nécessaires pour les ressources EKS et EC2.
- **Sécurité :** Examinez les règles des groupes de sécurité et les politiques IAM pour vous assurer qu'elles répondent à vos exigences de sécurité.

## Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Remerciements

- [Module Terraform AWS EKS](https://github.com/terraform-aws-modules/terraform-aws-eks)
- [Module Terraform AWS VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc)

Ce `README.md` fournit un guide complet pour la construction et la gestion de votre cluster EKS en utilisant Terraform. Assurez-vous de personnaliser les valeurs et les instructions spécifiques à votre environnement et à vos exigences.