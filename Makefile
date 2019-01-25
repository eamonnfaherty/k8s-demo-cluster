.PHONEY: create-clusters create-development-cluster create-production-cluster create-tiller-service-account

include default.properties

create-tiller-service-account:
	aws eks update-kubeconfig --name $(cluster_name)
	kubectl create serviceaccount tiller --namespace kube-system
	kubectl apply -f k8s/rbac-config.yaml
	helm init --service-account tiller
	kubectl get pods --namespace kube-system | grep tiller


create-development-cluster:
	$(MAKE) -C k8s create-master \
		cluster_name=$(development.cluster_name) \
		ssh_key_pair_name=$(development.ssh_key_pair_name) \
		cidr_vpc=$(development.cidr_vpc) \
		cidr_a_public=$(development.cidr_a_public) \
		cidr_a_private=$(development.cidr_a_private) \
		cidr_b_public=$(development.cidr_b_public) \
		cidr_b_private=$(development.cidr_b_private) \
		cidr_c_public=$(development.cidr_c_public) \
		cidr_c_private=$(development.cidr_c_private)
	$(MAKE) create-tiller-service-account cluster_name=$(development.cluster_name)
	$(MAKE) -C k8s create-nodes cluster_name=$(production.cluster_name) ssh_key_pair_name=$(development.ssh_key_pair_name)


create-production-cluster:
	$(MAKE) -C k8s create-master \
		cluster_name=$(production.cluster_name) \
		ssh_key_pair_name=$(production.ssh_key_pair_name) \
		cidr_vpc=$(production.cidr_vpc) \
		cidr_a_public=$(production.cidr_a_public) \
		cidr_a_private=$(production.cidr_a_private) \
		cidr_b_public=$(production.cidr_b_public) \
		cidr_b_private=$(production.cidr_b_private) \
		cidr_c_public=$(production.cidr_c_public) \
		cidr_c_private=$(production.cidr_c_private)
	$(MAKE) create-tiller-service-account cluster_name=$(production.cluster_name)
	$(MAKE) -C k8s create-nodes cluster_name=$(production.cluster_name) ssh_key_pair_name=$(production.ssh_key_pair_name)


create-clusters: create-development-cluster create-production-cluster
