if [ $# -ne 2 ]; then
  echo "Error! You should give me two arguments"
  exit 1;
fi
machine_db=$1
pkg_to_dl=$2

db_hash=`md5sum $machine_db|cut -d ' ' -f 1`
base_dir="/tmp/pacoff-$db_hash"
if [ ! -d $base_dir ]; then
  echo "Extracting..."
  mkdir -p $base_dir
  bsdtar -xf $machine_db -C $base_dir
else
  echo "Directory already found"
fi

chroot_pac="pacman -b $base_dir/var/lib/pacman -r $base_dir"
$chroot_pac -Sy
$chroot_pac -Sp $pkg_to_dl |
while read line 
do
  echo $line
  wget "$line" -c -nv -P $base_dir
done

repo-add $base_dir/repo.db.tar.gz $base_dir/*.tar.gz
mkdir -p pacman-offline
mv $base_dir/repo.db.tar.gz pacman-offline
mv $base_dir/*.tar.gz pacman-offline
