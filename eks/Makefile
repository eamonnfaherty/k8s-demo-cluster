.PHONY: \
	create-networking-layer create-cluster create-master create-nodegroup \
	update-networking-layer update-cluster update-master update-nodegroup \
	setup-utils


EKS_TEMPLATE=eks-cluster.yaml
EKS_STACKNAME=$(cluster_name)-cluster
EKS_CLUSTERNAME=$(cluster_name)

NODE_TEMPLATE=eks-nodes.yaml
NODE_STACKNAME=$(EKS_STACKNAME)-nodegroup

INSTANCE_ROLE_ARN := "$(shell aws cloudformation list-exports --query 'Exports[?Name==`$(NODE_STACKNAME)::InstanceRoleARN`].Value' --output text)"


create-networking-layer:
	aws cloudformation create-stack \
		--stack-name $(EKS_STACKNAME)-networking \
		--template-body file://amazon-eks-vpc.yaml \
		--parameters \
			ParameterKey=VpcBlock,ParameterValue=$(cidr_vpc) \
			ParameterKey=Subnet01Block,ParameterValue=$(subnet_01_block) \
			ParameterKey=Subnet02Block,ParameterValue=$(subnet_02_block) \
			ParameterKey=Subnet03Block,ParameterValue=$(subnet_03_block)
	aws cloudformation wait stack-create-complete --stack-name $(EKS_STACKNAME)-networking


create-master:
	aws cloudformation create-stack \
		--stack-name $(EKS_STACKNAME)-master \
		--template-body file://amazon-eks-master.yaml \
		--capabilities CAPABILITY_IAM \
		--parameters \
			ParameterKey=ClusterName,ParameterValue=$(cluster_name) \
			ParameterKey=EKSVersion,ParameterValue=$(eks_version) \
			ParameterKey=NetworkingStackName,ParameterValue=$(EKS_STACKNAME)-networking
	aws cloudformation wait stack-create-complete --stack-name $(EKS_STACKNAME)-master
	@cat aws-auth-cm.yaml.template | sed 's|NODE_INSTANCE_ROLE_ARN|$(INSTANCE_ROLE_ARN)|g' > aws-auth-cm.yaml
	aws eks update-kubeconfig --name $(cluster_name)
	kubectl apply -f aws-auth-cm.yaml

create-nodegroup:
	aws cloudformation create-stack \
		--stack-name $(EKS_STACKNAME)-nodegroup \
		--template-body file://amazon-eks-nodegroup.yaml \
		--capabilities CAPABILITY_IAM \
		--parameters \
			ParameterKey=KeyName,ParameterValue=$(ssh_key_pair_name) \
			ParameterKey=NodeInstanceType,ParameterValue=$(node_instance_type) \
			ParameterKey=NodeAutoScalingGroupMinSize,ParameterValue=$(node_autoscaling_group_min_size) \
			ParameterKey=NodeAutoScalingGroupMaxSize,ParameterValue=$(node_autoscaling_group_max_size) \
			ParameterKey=NodeAutoScalingGroupDesiredCapacity,ParameterValue=$(node_autoscaling_group_desired_capacity) \
			ParameterKey=NodeVolumeSize,ParameterValue=$(node_volume_size) \
			ParameterKey=BootstrapArguments,ParameterValue=$(bootstrap_arguments) \
			ParameterKey=NodeGroupName,ParameterValue=$(node_group_name) \
			ParameterKey=ClusterName,ParameterValue=$(cluster_name) \
			ParameterKey=NetworkingStackName,ParameterValue=$(EKS_STACKNAME)-networking
	aws cloudformation wait stack-create-complete --stack-name $(EKS_STACKNAME)-nodegroup

setup-utils:
	aws eks update-kubeconfig --name $(cluster_name)
	kubectl create serviceaccount tiller --namespace kube-system
	kubectl apply -f rbac-config.yaml
	helm init --service-account tiller

create-cluster: create-networking-layer create-master create-nodegroup setup-utils


update-networking-layer:
	aws cloudformation update-stack \
		--stack-name $(EKS_STACKNAME)-networking \
		--template-body file://amazon-eks-vpc.yaml \
		--parameters \
			ParameterKey=VpcBlock,ParameterValue=$(cidr_vpc) \
			ParameterKey=Subnet01Block,ParameterValue=$(subnet_01_block) \
			ParameterKey=Subnet02Block,ParameterValue=$(subnet_02_block) \
			ParameterKey=Subnet03Block,ParameterValue=$(subnet_03_block)
	aws cloudformation wait stack-update-complete --stack-name $(EKS_STACKNAME)-networking


update-master:
	aws cloudformation update-stack \
		--stack-name $(EKS_STACKNAME)-master \
		--template-body file://amazon-eks-master.yaml \
		--capabilities CAPABILITY_IAM \
		--parameters \
			ParameterKey=ClusterName,ParameterValue=$(cluster_name) \
			ParameterKey=EKSVersion,ParameterValue=$(eks_version) \
			ParameterKey=NetworkingStackName,ParameterValue=$(EKS_STACKNAME)-networking
	aws cloudformation wait stack-update-complete --stack-name $(EKS_STACKNAME)-master

update-nodegroup:
	@cat aws-auth-cm.yaml.template | sed 's|NODE_INSTANCE_ROLE_ARN|$(INSTANCE_ROLE_ARN)|g' > aws-auth-cm.yaml
	aws eks update-kubeconfig --name $(cluster_name)
	kubectl apply -f aws-auth-cm.yaml
	aws cloudformation update-stack \
		--stack-name $(EKS_STACKNAME)-nodegroup \
		--template-body file://amazon-eks-nodegroup.yaml \
		--capabilities CAPABILITY_IAM \
		--parameters \
			ParameterKey=KeyName,ParameterValue=$(ssh_key_pair_name) \
			ParameterKey=NodeInstanceType,ParameterValue=$(node_instance_type) \
			ParameterKey=NodeAutoScalingGroupMinSize,ParameterValue=$(node_autoscaling_group_min_size) \
			ParameterKey=NodeAutoScalingGroupMaxSize,ParameterValue=$(node_autoscaling_group_max_size) \
			ParameterKey=NodeAutoScalingGroupDesiredCapacity,ParameterValue=$(node_autoscaling_group_desired_capacity) \
			ParameterKey=NodeVolumeSize,ParameterValue=$(node_volume_size) \
			ParameterKey=BootstrapArguments,ParameterValue=$(bootstrap_arguments) \
			ParameterKey=NodeGroupName,ParameterValue=$(node_group_name) \
			ParameterKey=ClusterName,ParameterValue=$(cluster_name) \
			ParameterKey=NetworkingStackName,ParameterValue=$(EKS_STACKNAME)-networking
	aws cloudformation wait stack-update-complete --stack-name $(EKS_STACKNAME)-nodegroup

