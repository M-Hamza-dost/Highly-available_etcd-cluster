# Highly-available_etcd-cluster


## Setting Up an ETCD Cluster with Vagrant and TLS Certificates

This project displays the successful setup of an **ETCD cluster** using **Vagrant**, configured with TLS certificates for secure communication, and running ETCD as a service.

## System Setup and Environment

To complete this setup, the following dependencies were installed:

- **VirtualBox**
- **Vagrant**
- **OpenSSL**

## ETCD Cluster Deployment

The cluster consists of three virtual machines (VMs) provisioned using a `Vagrantfile`. Each VM is assigned a private IP address to communicate internally within the cluster.

After provisioning the VMs, navigate to the `etcd-binaries` directory, where the required binaries were downloaded and installed using the following commands:

```sh
wget -q --show-progress https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl_1.6.4_linux_amd64
```
```sh
wget -q --show-progress https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssljson_1.6.4_linux_amd64
```
```sh
# Provide executable permissions
chmod +x cfssl_1.6.4_linux_amd64 cfssljson_1.6.4_linux_amd64
```
```sh
# Move binaries to /usr/local/bin
sudo mv cfssl_1.6.4_linux_amd64 /usr/local/bin/cfssl
sudo mv cfssljson_1.6.4_linux_amd64 /usr/local/bin/cfssljson
```

## Certificate Authority (CA) Creation

To secure communication, a **Certificate Authority (CA)** was generated.

### Generate CA Certificate

```sh
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```

This will create `ca.pem` and `ca-key.pem` files.

### Generate ETCD Certificates

```sh
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-csr.json | cfssljson -bare etcd
```

This will create `etcd.pem` and `etcd-key.pem` files.

## Certificate Distribution

Run the `copy_files.sh` script in the `etcd-binaries` directory to distribute certificates to each node:
```sh
chmod +x copy_files.sh
```
```sh
./copy_files.sh
```

## ETCD Configuration

The generated certificates were securely copied to each ETCD node. A systemd service file was then defined **on each node** to configure and manage the ETCD service, ensuring authentication via TLS.

> **Note:** The `NODE_IP` in the following configuration file will be changed for each node.

### ETCD Service Configuration

```sh
NODE_IP="192.168.56.11"
ETCD1_IP="192.168.56.11"
ETCD2_IP="192.168.56.12"
ETCD_NAME=$(hostname -s)

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/pki/etcd.pem \\
  --key-file=/etc/etcd/pki/etcd-key.pem \\
  --peer-cert-file=/etc/etcd/pki/etcd.pem \\
  --peer-key-file=/etc/etcd/pki/etcd-key.pem \\
  --trusted-ca-file=/etc/etcd/pki/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/pki/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${NODE_IP}:2380 \\
  --listen-peer-urls https://${NODE_IP}:2380 \\
  --advertise-client-urls https://${NODE_IP}:2379 \\
  --listen-client-urls https://${NODE_IP}:2379,https://127.0.0.1:2379 \\
  --initial-cluster-token etcd-cluster-1 \\
  --initial-cluster etcd1=https://${ETCD1_IP}:2380,etcd2=https://${ETCD2_IP}:2380 \\
  --initial-cluster-state new
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
```

## Service Deployment and Cluster Verification

After configuring systemd, the ETCD service was started and enabled on all nodes.
The cluster’s health was verified using the following command:
```sh
etcdctl --cacert=/etc/etcd/pki/ca.pem --cert=/etc/etcd/pki/etcd.pem --key=/etc/etcd/pki/etcd-key.pem endpoint health
```

The output confirmed that all ETCD nodes were healthy and securely communicating.

## Persistent Environment Variables

To permanently store API version and certificate paths for `etcdctl`, the following environment variables can be added to `.bashrc` or `.profile` file:

```sh
echo "export ETCDCTL_API=3" >> ~/.bashrc
echo "export ETCDCTL_ENDPOINTS=https://192.168.56.11:2379,https://192.168.56.12:2379,https://192.168.56.13:2379" >> ~/.bashrc
echo "export ETCDCTL_CACERT=/etc/etcd/pki/ca.pem" >> ~/.bashrc
echo "export ETCDCTL_CERT=/etc/etcd/pki/etcd.pem" >> ~/.bashrc
echo "export ETCDCTL_KEY=/etc/etcd/pki/etcd-key.pem" >> ~/.bashrc
source ~/.bashrc
```

![Screenshot](https://github.com/M-Hamza-dost/Highly-available_etcd-cluster/blob/main/diagram.png)


## Conclusion

The **ETCD cluster** was successfully set up with **TLS authentication**, ensuring secure and reliable key-value storage for distributed applications. Contributions and improvements are welcome — feel free to explore and enhance this repository!



