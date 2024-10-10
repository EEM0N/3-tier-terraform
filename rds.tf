
# Create a DB subnet group for RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = aws_subnet.private_subnet_db_tier[*].id

  tags = {
    Name = "Database Subnet Group"
  }
}

#Create RDS Amazon Aurora cluster
resource "aws_rds_cluster" "rds_cluster" {
    cluster_identifier = "labvpcdbcluster"
    engine = "aurora-mysql"
    engine_version = "5.7.mysql_aurora.2.07.2"
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
    database_name = "testing"
    master_username = "admin"
    master_password = "admin"
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    apply_immediately = true
    skip_final_snapshot = true
}

#Create RDS Amazon Aurora cluster instance - Multi AZ
resource "aws_rds_cluster_instance" "rds_instances" {
    count = 2
    identifier = "rds-instance-${count.index}"
    cluster_identifier = aws_rds_cluster.rds_cluster.id 
    engine = aws_rds_cluster.rds_cluster.engine
    engine_version = aws_rds_cluster.rds_cluster.engine_version
    instance_class = "db.t3.small"
    publicly_accessible = false
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
} 