### Directory structure

```
main.tf
variables.tf
modules/
└── instances
    ├── instances.tf
    ├── outputs.tf
    └── variables.tf
└── storage
    ├── storage.tf
    ├── outputs.tf
    └── variables.tf
```

The example below will import an AWS instance into the aws_instance resource named bar into a module named foo:

```
terraform import module.foo.aws_instance.bar i-abcd1234
terraform import module.instances.google_compute_instance.tf-instance-1 
``` 
terraform apply -replace="module.instances.google_compute_instance.tf-instance-813516"