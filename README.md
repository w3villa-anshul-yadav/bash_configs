### Execute These commands form cloned repo directory

```
echo -e "\n# Source custom terminal settings if available\nif [ -f $(pwd)/.custom_terminal ]; then\n    . $(pwd)/.custom_terminal\nfi" | tee -a ~/.bashrc && \
echo -e "\n# Source bash aliases settings if available\nif [ -f $(pwd)/.bash_aliases ]; then\n    . $(pwd)/.bash_aliases\nfi" | tee -a ~/.bashrc && \
source ~/.bashrc \
chmod +x setup.sh
sudo ./setup.sh

```

