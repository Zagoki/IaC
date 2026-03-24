# Infrastructure as Code - Terraform Practice

Projet d'apprentissage Terraform - Déploiement d'une infrastructure AWS avec Nginx et PostgreSQL.

## 📋 Exercices Implémentés

### ✅ Exercice 1 - Variables
Déclaration de variables Terraform pour les valeurs configurables :
- `instance_type` : Type d'instance EC2 (défaut: "t2.micro")
- `instance_name` : Nom de l'instance web (défaut: "nginx-server")
- `bucket_name` : Nom du bucket S3 (défaut: "my-bucket")
- `http_port` : Port HTTP pour le groupe de sécurité (défaut: 80)

**Fichier** : `TP-local/variables.tf`

---

### ✅ Exercice 2 - Outputs
Affichage des identifiants et informations des ressources créées :
- `bucket_id` : Identifiant du bucket S3
- `instance_id` : ID du serveur web EC2
- `instance_public_ip` : Adresse IP publique du serveur web
- `database_instance_id` : ID de l'instance base de données
- `database_instance_public_ip` : Adresse IP de la base de données
- Commandes SSH pour accès aux instances

**Fichier** : `TP-local/outputs.tf`

---

### ✅ Exercice 3 - Nouvelle Instance EC2
Déploiement d'une deuxième instance EC2 dédiée à la base de données :
- Nouvelle ressource `aws_instance.database`
- Installation automatique de PostgreSQL 15
- Configuration PostgreSQL automatisée
- Security group dédié pour la base de données
- Tag identifiant pour faciliter la gestion

**Fichier** : `TP-local/ec2.tf`

---

### ✅ Exercice 4 - Données Dynamiques
Utilisation de sources de données (data sources) pour récupérer les AMI disponibles dynamiquement au lieu de les coder en dur.

**Fichier** : `TP-local/main.tf`, `TP-local/ec2.tf`

---

### ✅ Exercice 5 - Boucles
Utilisation des boucles Terraform (`for_each`, `count`) pour :
- Créer plusieurs ressources similaires
- Itérer sur les machines définies

**Fichier** : `TP-local/*.tf`

---

### ✅ Exercice 6 - Conditionnels
Utilisation de conditions Terraform (`if`/`ternary`) pour :
- Configuration conditionnelle des ressources
- Déploiement optionnel de composants

**Fichier** : `TP-local/*.tf`

---

### ✅ Exercice 7 - Utilisation des Types de Variables
Variable `machines` de type liste d'objets avec validations personnalisées :
```hcl
variable "machines" {
  type = list(object({
    name      = string        # Nom de la machine
    vcpu      = number        # vCPU (min: 2, max: 64)
    disk_size = number        # Taille disque en Go (min: 20)
    region    = string        # Région AWS valide
  }))
}
```

**Validations** :
- ✅ vCPU entre 2 et 64
- ✅ Taille disque >= 20 Go
- ✅ Région parmi : "eu-west-1", "us-east-1", "ap-southeast-1"

**Fichier** : `TP-local/variables.tf`

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         AWS CloudProvider               │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ EC2 Instance │  │ EC2 Instance │   │
│  │   (Nginx)    │  │ (PostgreSQL) │   │
│  │              │  │              │   │
│  └──────────────┘  └──────────────┘   │
│        │ SSH            │ SSH          │
│        └────────┬───────┘              │
│                 │                      │
│         ┌───────────────┐              │
│         │ Security Group│              │
│         │   (SSH, HTTP) │              │
│         └───────────────┘              │
│                                         │
│         ┌─────────────┐                │
│         │ S3 Bucket   │                │
│         │ (Static)    │                │
│         └─────────────┘                │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📁 Structure du Projet

```
TP-local/
├── main.tf              # Configuration AWs provider
├── ec2.tf              # Instances EC2 (Web + Database)
├── s3.tf               # Bucket S3 + fichiers
├── sg.tf               # Security Groups
├── variables.tf        # Définition des variables
├── outputs.tf          # Outputs
└── terraform.tfstate   # État Terraform (local)
```

---

## 🚀 Démarrage Rapide

### Prérequis
- Terraform >= 1.0
- AWS CLI configurée avec les credentials
- Ou LocalStack pour un environnement local

### Installation

```bash
cd TP-local/

# Initialiser Terraform
terraform init

# Valider la configuration
terraform validate

# Voir les changements prévus
terraform plan

# Appliquer la configuration
terraform apply

# Afficher les outputs
terraform output
```

### Nettoyage

```bash
terraform destroy
```

---


### Npour deployer sur aws

cd TP-local

# 1. Configurer AWS CLI
aws configure

# 2. Trouver l'AMI correcte pour votre région
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text

# 3. Adapter ec2.tf avec l'AMI trouvée

# 4. Déployer
terraform init
terraform apply

# 5. Accéder via SSH
ssh -i deployer-key.pem ec2-user@<IP_PUBLIQUE>

---

## 📊 Ressources Créées

| Ressource | Type | Description |
|-----------|------|-------------|
| `aws_instance.web` | EC2 | Serveur web Nginx |
| `aws_instance.database` | EC2 | Serveur PostgreSQL |
| `aws_security_group.web` | Security Group | Règles pour web (SSH + HTTP) |
| `aws_security_group.database` | Security Group | Règles pour DB (SSH + PostgreSQL) |
| `aws_s3_bucket.demo_bucket` | S3 | Bucket de stockage statique |
| `aws_key_pair.deployer` | Key Pair | Paire de clés SSH |
| `tls_private_key.key` | TLS | Génération clé privée RSA |
| `local_file.private_key` | Local | Sauvegarde clé RSA locale |

---

## 🔐 Accès SSH

Une fois déployé, récupérez l'adresse IP publique et connectez-vous :

```bash
ssh -i deployer-key.pem ec2-user@<IP_PUBLIQUE>
```

---

## 📝 Variables Customisables

Créez un fichier `terraform.tfvars` pour override les valeurs :

```hcl
instance_type = "t2.small"
instance_name = "my-nginx-server"
bucket_name   = "my-custom-bucket"
http_port     = 8080
db_instance_name = "my-postgres-server"

machines = [
  {
    name      = "vm-prod-1"
    vcpu      = 4
    disk_size = 100
    region    = "eu-west-1"
  }
]
```

---

## 📚 Ressources Utiles

- [Documentation Terraform](https://www.terraform.io/docs)
- [Hashicorp AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Best Practices](https://www.terraform.io/language)

---

## 👤 Auteur

Exercices de formation - Infrastructure as Code avec Terraform
