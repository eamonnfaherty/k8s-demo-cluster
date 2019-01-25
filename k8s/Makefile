.PHONY: validate-templates create-master create-nodes create update-master update-nodes delete-master delete-nodes delete register-nodes

ifndef cluster_name
$(error 'cluster_name is not defined')
endif

EKS_TEMPLATE=eks-cluster.yaml
EKS_STACKNAME=$(cluster_name)-cluster
EKS_CLUSTERNAME=$(cluster_name)

NODE_TEMPLATE=eks-nodes.yaml
NODE_STACKNAME=$(cluster_name)-nodes

INSTANCE_ROLE_ARN := "$(shell aws cloudformation list-exports --query 'Exports[?Name==`$(NODE_STACKNAME)::InstanceRoleARN`].Value' --output text)"

validate-templates:
	aws cloudformation validate-template --template-body file://$(EKS_TEMPLATE)
	aws cloudformation validate-template --template-body file://$(NODE_TEMPLATE)

create-master:
	aws cloudformation create-stack \
		--stack-name $(EKS_STACKNAME) \
		--template-body file://$(EKS_TEMPLATE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			ParameterKey=ClusterName,ParameterValue=$(EKS_CLUSTERNAME) \
			ParameterKey=EKSVersion,ParameterValue=1.10 \
			ParameterKey=CidrVPC,ParameterValue=$(cidr_vpc) \
			ParameterKey=CidrAPublic,ParameterValue=$(cidr_a_public) \
			ParameterKey=CidrAPrivate,ParameterValue=$(cidr_a_private) \
			ParameterKey=CidrBPublic,ParameterValue=$(cidr_b_public) \
			ParameterKey=CidrBPrivate,ParameterValue=$(cidr_b_private) \
			ParameterKey=CidrCPublic,ParameterValue=$(cidr_c_public) \
			ParameterKey=CidrCPrivate,ParameterValue=$(cidr_c_private)
	aws cloudformation wait stack-create-complete --stack-name $(EKS_STACKNAME)

create-nodes:
	aws cloudformation create-stack \
		--stack-name $(NODE_STACKNAME) \
		--template-body file://$(NODE_TEMPLATE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			ParameterKey=ClusterName,ParameterValue=$(EKS_CLUSTERNAME) \
			ParameterKey=ClusterStackName,ParameterValue=$(EKS_STACKNAME) \
			ParameterKey=NodeInstanceType,ParameterValue=t2.medium \
			ParameterKey=KeyName,ParameterValue=$(ssh_key_pair_name)
	aws cloudformation wait stack-create-complete --stack-name $(NODE_STACKNAME)

register-nodes:
	@cat aws-auth-cm.yaml.template | sed 's|NODE_INSTANCE_ROLE_ARN|$(INSTANCE_ROLE_ARN)|g' > aws-auth-cm.yaml
	aws eks update-kubeconfig --name $(cluster_name)
	kubectl apply -f aws-auth-cm.yaml

create: create-master create-nodes register-nodes

update-master:
	aws cloudformation update-stack \
		--stack-name $(EKS_STACKNAME) \
		--template-body file://$(EKS_TEMPLATE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters ParameterKey=ClusterName,ParameterValue=$(EKS_CLUSTERNAME) ParameterKey=EKSVersion,ParameterValue=1.10
	aws cloudformation wait stack-update-complete --stack-name $(EKS_STACKNAME)

update-nodes:
	aws cloudformation update-stack \
		--stack-name $(NODE_STACKNAME) \
		--template-body file://$(NODE_TEMPLATE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameters \
			ParameterKey=ClusterName,ParameterValue=$(EKS_CLUSTERNAME) \
			ParameterKey=ClusterStackName,ParameterValue=$(EKS_STACKNAME) \
			ParameterKey=NodeInstanceType,ParameterValue=t2.medium \
			ParameterKey=KeyName,ParameterValue=foo
	aws cloudformation wait stack-update-complete --stack-name $(NODE_STACKNAME)

delete-master:
	aws cloudformation delete-stack \
		--stack-name $(EKS_STACKNAME)
	aws cloudformation wait stack-delete-complete --stack-name $(EKS_STACKNAME)

delete-nodes:
	aws cloudformation delete-stack \
		--stack-name $(NODE_STACKNAME)
	aws cloudformation wait stack-delete-complete --stack-name $(EKS_STACKNAME)

delete: delete-nodes delete-master