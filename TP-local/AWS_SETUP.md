# Configuration AWS - Exercice 4

Ce document explique comment déployer cette infrastructure sur un compte AWS réel.

## 📋 Prérequis

- Compte AWS avec accès administrateur (ou droits pour créer EC2, S3, Security Groups, Key Pairs)
- AWS CLI configurée avec les credentials
- Terraform >= 1.0
- Une région AWS (défaut: us-east-1)

## 🔧 Configuration AWS

### 1. Configurer AWS CLI

```bash
aws configure

# Entrez vos credentials:
# AWS Access Key ID: [votre access key]
# AWS Secret Access Key: [votre secret key]
# Default region: us-east-1 (ou votre région préférée)
# Default output format: json
```

### 2. Adapter la région (optionnel)

Modifiez `TP-local/main.tf` pour changer la région :

```hcl
provider "aws" {
  region = "eu-west-1"  # Ou votre région préférée
}
```

### 3. Adapter l'AMI pour votre région

L'AMI `ami-12345678` est un **placeholder**. Vous devez utiliser l'AMI officielle Amazon Linux 2 pour votre région.

#### Pour trouver l'AMI correcte :

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text
```

Puis mettez à jour `TP-local/ec2.tf` avec l'AMI retournée:

```hcl
resource "aws_instance" "web" {
  ami = "ami-0c55b159cbfafe1f0"  # Remplacez avec votre AMI
  ...
}

resource "aws_instance" "database" {
  ami = "ami-0c55b159cbfafe1f0"  # Même AMI
  ...
}
```

## 🚀 Déploiement

### Initialiser Terraform

```bash
cd TP-local
terraform init
```

### Valider la configuration

```bash
terraform validate
```

### Afficher le plan (optionnel)

```bash
terraform plan
```

### Appliquer la configuration

```bash
terraform apply

# Confirmez avec 'yes' quand demandé
```

### Récupérer les outputs

```bash
terraform output

# Vous verrez:
# - Les IDs des instances EC2
# - Les adresses IP publiques
# - Les commandes SSH pour tester
```

## 🔐 Accès SSH aux instances

Une fois déployé, Terraform crée automatiquement une paire de clés SSH et un fichier `deployer-key.pem`.

### Connectez-vous au serveur Nginx

```bash
ssh -i deployer-key.pem ec2-user@<IP_PUBLIQUE_WEB>

# Vérifiez Nginx
curl localhost
```

### Connectez-vous au serveur PostgreSQL

```bash
ssh -i deployer-key.pem ec2-user@<IP_PUBLIQUE_DB>

# Vérifiez PostgreSQL
psql --version
```

## 📊 Ressources créées sur AWS

| Ressource | Nom | Type |
|-----------|-----|------|
| Serveur Web | nginx-server | EC2 Instance |
| Serveur DB | database-server | EC2 Instance |
| Groupe Sécurité Web | nginx-sg | Security Group |
| Groupe Sécurité DB | database-sg | Security Group |
| Bucket S3 | my-bucket | S3 Bucket |
| Paire de clés | deployer-key | Key Pair |

## 🧹 Nettoyage

Pour supprimer toutes les ressources créées :

```bash
terraform destroy

# Confirmez avec 'yes'
```

⚠️ **ATTENTION** : `terraform destroy` supprimera :
- Les instances EC2
- Les security groups
- Le bucket S3 (avec les données)
- La paire de clés

## 💰 Estimation des coûts

Sur la couche gratuite AWS :
- ✅ 750 heures EC2 t2.micro/t2.small par mois (gratuit 12 mois)
- ✅ 5 GB de stockage S3 gratuit
- ✅ 20 000 requêtes PUT/GET S3 gratuites

**Total estimé** : Gratuit les 12 premiers mois si vous utilisez t2.micro

## 🐛 Dépannage

### Erreur : "InvalidKeyPair.Duplicate"
La paire de clés existe déjà dans AWS. Supprimez-la manuellement ou changez le nom dans `ec2.tf`.

### Erreur : "InvalidAMIID.NotFound"
L'AMI n'existe pas dans votre région. Utilisez la commande ci-dessus pour trouver l'AMI correcte.

### Erreur : "UnauthorizedOperation"
Vos credentials AWS ne sont pas valides. Vérifiez avec :
```bash
aws sts get-caller-identity
```

### Les instances ne répondent pas au ping
Attendez 2-3 minutes que les instances soient complètement démarrées et que le `user_data` soit exécuté.

## 📚 Ressources utiles

- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
