.PHONEY: create-clusters create-development-cluster create-production-cluster

include default.properties

create-development-cluster:
	$(MAKE) -C k8s create-master \
		cluster_name=$(development.cluster_name) \
		cidr_vpc=$(development.cidr_vpc) \
		cidr_a_public=$(development.cidr_a_public) \
		cidr_a_private=$(development.cidr_a_private) \
		cidr_b_public=$(development.cidr_b_public) \
		cidr_b_private=$(development.cidr_b_private) \
		cidr_c_public=$(development.cidr_c_public) \
		cidr_c_private=$(development.cidr_c_private)

create-production-cluster:
	$(MAKE) -C k8s create-master \
		cluster_name=$(production.cluster_name) \
		cidr_vpc=$(production.cidr_vpc) \
		cidr_a_public=$(production.cidr_a_public) \
		cidr_a_private=$(production.cidr_a_private) \
		cidr_b_public=$(production.cidr_b_public) \
		cidr_b_private=$(production.cidr_b_private) \
		cidr_c_public=$(production.cidr_c_public) \
		cidr_c_private=$(production.cidr_c_private)

create-clusters: create-development-cluster create-production-cluster
