# Copy entrypoint
cp /tmp/artifacts/entrypoint.sh /
chown 0:0 /entrypoint.sh

# Setup $PS1 for a consistent and reasonable prompt
echo "export PS1='\W \`git branch --show-current 2>/dev/null | sed -r -e \"s@^(.+)@\(\1\) @\"\`$ '" >> /home/user/.bashrc
# Set permissions on /etc/passwd and /home to allow arbitrary users to write
chgrp -R 0 /home /etc/passwd /etc/group /etc/subuid /etc/subgid /home ${WORK_DIR}

# Setup for root-less podman
mkdir -p "${HOME}"/.config/containers;
mkdir -p "${HOME}/.cache"
setcap cap_setuid+ep /usr/bin/newuidmap;
setcap cap_setgid+ep /usr/bin/newgidmap;
touch /etc/subgid /etc/subuid;
chmod +x /entrypoint.sh;
chmod -R g=u /etc/passwd /etc/group /etc/subuid /etc/subgid /home ${WORK_DIR}

# Setup for dynamic oc & kubectl
ln -s /projects/bin/oc /usr/local/bin/oc;
ln -s /projects/bin/kubectl /usr/local/bin/kubectl;

# Detect package manager and make sure packages are up to date
pkg_mgr=""
if command -v dnf &> /dev/null
then
    pkg_mgr=dnf
elif command -v microdnf &> /dev/null
then
    pkg_mgr=microdnf
else
    echo "No compatible package manager could not be found"
    exit 1
fi

$pkg_mgr update -y
$pkg_mgr clean -y all
