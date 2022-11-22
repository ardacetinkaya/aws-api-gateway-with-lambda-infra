# resource "aws_instance" "vm_instance_01" {
#   ami                           = "ami-0440e5026412ff23f"
#   instance_type                 = "t3.nano"
#   subnet_id                     = aws_subnet.subnet_01.id
#   hibernation                   = false  

#   security_groups = [ 
#     "${aws_security_group.security_group_01.id}",
#     "${aws_security_group.security_group_02.id}"
#   ]

#   provider = aws.primary-region
#   tags = {
#     Name = "test-vm"
#   }
# }