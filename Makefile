.PHONEY: create-clusters create-development-cluster create-production-cluster create-tiller-service-account

include default.properties

create-tiller-service-account:
	aws eks update-kubeconfig --name $(cluster_name)
	kubectl create serviceaccount tiller --namespace kube-system
	kubectl apply -f k8s/rbac-config.yaml
	helm init --service-account tiller
	kubectl get pods --namespace kube-system | grep tiller


create-development-cluster:
	$(MAKE) -C eks create-cluster \
		cluster_name=$(development.cluster_name) \
		eks_version=$(development.eks_version) \
		cidr_vpc=$(development.cidr_vpc) \
		cidr_vpc=$(development.cidr_vpc) \
		subnet_01_block=$(development.subnet_01_block) \
		subnet_02_block=$(development.subnet_02_block) \
		subnet_03_block=$(development.subnet_03_block) \
		ssh_key_pair_name=$(development.ssh_key_pair_name) \
		node_instance_type=$(development.node_instance_type) \
		node_autoscaling_group_min_size=$(development.node_autoscaling_group_min_size) \
		node_autoscaling_group_max_size=$(development.node_autoscaling_group_max_size) \
		node_autoscaling_group_desired_capacity=$(development.node_autoscaling_group_desired_capacity) \
		node_volume_size=$(development.node_volume_size) \
		bootstrap_arguments=$(development.bootstrap_arguments) \
		node_group_name=$(development.node_group_name)


update-development-cluster:
	$(MAKE) -C eks update-cluster \
		cluster_name=$(development.cluster_name) \
		eks_version=$(development.eks_version) \
		cidr_vpc=$(development.cidr_vpc) \
		cidr_vpc=$(development.cidr_vpc) \
		subnet_01_block=$(development.subnet_01_block) \
		subnet_02_block=$(development.subnet_02_block) \
		subnet_03_block=$(development.subnet_03_block) \
		ssh_key_pair_name=$(development.ssh_key_pair_name) \
		node_instance_type=$(development.node_instance_type) \
		node_autoscaling_group_min_size=$(development.node_autoscaling_group_min_size) \
		node_autoscaling_group_max_size=$(development.node_autoscaling_group_max_size) \
		node_autoscaling_group_desired_capacity=$(development.node_autoscaling_group_desired_capacity) \
		node_volume_size=$(development.node_volume_size) \
		bootstrap_arguments=$(development.bootstrap_arguments) \
		node_group_name=$(development.node_group_name)

#create-development-cluster:
#	$(MAKE) -C k8s create-master \
#		cluster_name=$(development.cluster_name) \
#		ssh_key_pair_name=$(development.ssh_key_pair_name) \
#		cidr_vpc=$(development.cidr_vpc) \
#		cidr_a_public=$(development.cidr_a_public) \
#		cidr_a_private=$(development.cidr_a_private) \
#		cidr_b_public=$(development.cidr_b_public) \
#		cidr_b_private=$(development.cidr_b_private) \
#		cidr_c_public=$(development.cidr_c_public) \
#		cidr_c_private=$(development.cidr_c_private)
#	sleep 10
#	$(MAKE) -C k8s create-nodes cluster_name=$(development.cluster_name) ssh_key_pair_name=$(development.ssh_key_pair_name)
#	sleep 10
#	$(MAKE) create-tiller-service-account cluster_name=$(development.cluster_name)
#
#
#create-production-cluster:
#	$(MAKE) -C k8s create-master \
#		cluster_name=$(production.cluster_name) \
#		ssh_key_pair_name=$(production.ssh_key_pair_name) \
#		cidr_vpc=$(production.cidr_vpc) \
#		cidr_a_public=$(production.cidr_a_public) \
#		cidr_a_private=$(production.cidr_a_private) \
#		cidr_b_public=$(production.cidr_b_public) \
#		cidr_b_private=$(production.cidr_b_private) \
#		cidr_c_public=$(production.cidr_c_public) \
#		cidr_c_private=$(production.cidr_c_private)
#	sleep 10
#	$(MAKE) -C k8s create-nodes cluster_name=$(production.cluster_name) ssh_key_pair_name=$(production.ssh_key_pair_name)
#	sleep 10
#	$(MAKE) create-tiller-service-account cluster_name=$(production.cluster_name)
#
#
#create-clusters: create-development-cluster create-production-cluster
