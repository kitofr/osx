```
# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "coinduction"
sudo scutil --set HostName "coinduction"
sudo scutil --set LocalHostName "coinduction"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "COINDUCTION"
```

`curl -o bootstrap.sh -L https://raw.githubusercontent.com/Intelliplan/osx/master/bootstrap.sh && chmod +x bootstrap.sh && ./bootstrap.sh`