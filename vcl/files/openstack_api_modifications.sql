insert into module (id, name, prettyname, description, perlpackage) values (26, 'provisioning_nova', 'Openstack Nova Module', '', 'VCL::Module::Provisioning::openstack');
insert into provisioning (id, name, prettyname, moduleid) values (9, 'openstack_nova', 'Openstack Nova', 26);
insert into OSinstalltype (id, name) values (6, 'openstack_nova');
insert into provisioningOSinstalltype (provisioningid, OSinstalltypeid) values (9, 6);
create table openstackImageNameMap(openstackimagename VARCHAR(60), vclimagename VARCHAR(60));
# According to: https://issues.apache.org/jira/browse/VCL-590?focusedCommentId=13416496#comment-13416496 moduleid should be 5 for linux
insert into OS (id,name,prettyname,type,installtype,sourcepath,moduleid) values (39, "rhel6openstack", "CentOS 6 OpenStack", "linux", "openstack_nova", "centos6", 5);
