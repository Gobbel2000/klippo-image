#!/bin/bash -e

REMOTE="https://github.com/Gobbel2000/svup.git"

SVUP_DIR="${STAGE_WORK_DIR}/svup"
mkdir "${SVUP_DIR}"
SVUP_SRC="${SVUP_DIR}/svup"
git clone "${REMOTE}" "${SVUP_SRC}"

pushd "${SVUP_SRC}" > /dev/null
dpkg-buildpackage -us -uc -b
popd > /dev/null

cp "${SVUP_DIR}"/svup*.deb "${ROOTFS_DIR}/"

on_chroot << EOF
dpkg --force-depends -i /svup*.deb
apt-get install --yes --fix-broken
EOF

rm "${ROOTFS_DIR}"/svup*.deb
