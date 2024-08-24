#/bin/sh

OUTDIR=t14s-packages

if [[ $1 != "--skip-build" ]]; then
    echo 'Building packages...'
    for pkg in "linux-t14s" "t14s-firmware" "t14s-keyring" ; do
        cd $pkg
        PKGEXT=.pkg.tar.xz CARCH=aarch64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nice -19 makepkg -sCA
        cd ..
    done
fi

[[ -d $OUTDIR ]] && rm -rf $OUTDIR
mkdir $OUTDIR && cd $OUTDIR

cp ../*/*.pkg.tar.xz ./

for pkg in *.pkg.tar.xz; do
    gpg --detach-sign "${pkg}"
done

repo-add --sign linux-t14s.db.tar.gz *.pkg.tar.xz

yes | gh release delete packages
gh release create packages --notes ""
gh release upload packages *
