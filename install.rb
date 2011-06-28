# Create temporary directory
mkdir ~/tmp-install
cd ~/tmp-install

# Install git
curl http://kernel.org/pub/software/scm/git/git-1.7.1.tar.gz -O
tar xzvf git-1.7.1.tar.gz
cd git-1.7.1
make configure 
./configure --prefix=/usr/local
NO_MSGFMT=yes make prefix=/usr/local all
sudo make install

# Configure git
git config --global user.name "My name" 
git config --global user.email "myname@kondensator.se"
git config --global --list
git config --global color.ui "auto"

# Installera realgrowl
hdid http://growl.cachefly.net/Growl-1.2.1-SDK.dmg
cp -r /Volumes/Growl\ 1.2.1\ SDK/Frameworks/Growl.framework /Library/Frameworks
sudo gem install real-growl

# Create application settings
mkdir ~/KONDENSATOR
touch ~/.fsmon
echo "user: victor" >> ~/.fsmon
echo "folders:" >> ~/.fsmon
echo "  - ~/KONDENSATOR/Customers" >> ~/.fsmon
echo "  - ~/KONDENSATOR/Documents" >> ~/.fsmon
echo "filters:" >> ~/.fsmon
echo "  - .DS_Store" >> ~/.fsmon
echo "  - .git" >> ~/.fsmon

# Clone the folder monitor project
git clone git://github.com/KONDENSATOR/k-folder-mon.git ~/.fsmond
cd ~/.fsmond
curl http://download.ksite.se/internt/fetool -O
chmod +x fetool

# Clone the working directories
cd ~/KONDENSATOR
git clone ssh://sparkle@xara.ksite.se:2222/SPARKLE/CUSTOMER ~/KONDENSATOR/Customers
git clone ssh://sparkle@xara.ksite.se:2222/SPARKLE/DOKUMENT ~/KONDENSATOR/Documents

sudo ./fsstartall

# Note, you must update your path where it say MYUSERNAME
defaults write loginwindow AutoLaunchedApplicationDictionary -array-add '<dict><key>Hide</key><false/><key>Path</key><string>/Users/victor/.fsmond/fsstartall</string></dict>'
