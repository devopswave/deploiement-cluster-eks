# Point de terminaison du plan de contrôle EKS

# Fournit l'URL du point de terminaison pour accéder au plan de contrôle de
# votre cluster EKS.
# Utilisé pour interagir avec l'API du cluster Kubernetes.
# Cela peut être nécessaire pour les outils de gestion ou pour la configuration des clients Kubernetes.
output "cluster_endpoint" {
  description = "Point de terminaison pour le plan de contrôle EKS."
  value       = module.eks.cluster_endpoint
}

# Identifiants des groupes de sécurité attachés au plan de contrôle du cluster

# Contient les identifiants des groupes de sécurité associés au plan de contrôle du cluster EKS.
# Permet de gérer les règles de sécurité réseau pour le plan de contrôle.
# Ces groupes de sécurité contrôlent le trafic entrant et sortant pour le plan de contrôle.
output "cluster_security_group_id" {
  description = "Identifiants des groupes de sécurité attachés au plan de contrôle du cluster."
  value       = module.eks.cluster_security_group_id
}

# Région AWS utilisée pour le déploiement

# Indique la région AWS dans laquelle le cluster EKS est déployé.
# Utile pour s'assurer que les ressources AWS sont créées et gérées dans la région correcte.
# Peut être utilisé dans les scripts ou pour la documentation.
output "region" {
  description = "Région AWS utilisée pour le déploiement."
  value       = var.region
}

# Nom du cluster Kubernetes

# Fournit le nom du cluster Kubernetes.
# Utile pour identifier le cluster EKS lors de l'exécution de commandes Kubernetes
# ou lors de la configuration des outils de gestion.
output "cluster_name" {
  description = "Nom du cluster Kubernetes."
  value       = module.eks.cluster_name
}