### Execute These commands form cloned repo directory

```
    cp .custom_terminal .bash_aliases ~/ ; echo -e "\n# Source custom terminal settings if available\nif [ -f ~/.custom_terminal ]; then\n    . ~/.custom_terminal\nfi" | tee -a ~/.bashrc && source ~/.bashrc ; echo -e "\n# Source bash aliases settings if available\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi" | tee -a ~/.bashrc && source ~/.bashrc

```

