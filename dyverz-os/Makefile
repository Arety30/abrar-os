# Dyverz OS — dev loop.  VM = the Arch VirtualBox VM (ssh port 2222)
VM ?= abrar@127.0.0.1
PORT ?= 2222
ED ?= all
SSH = ssh -p $(PORT) $(VM)

sync:            ## copy this repo to the VM (~/dyverz-os)
	rsync -a --delete -e "ssh -p $(PORT)" ./ $(VM):dyverz-os/
stack: sync      ## install the whole stack + overlay into the running VM
	$(SSH) 'sudo ~/dyverz-os/scripts/install-stack.sh $(ED)'
overlay: sync    ## re-apply only the scripts/config overlay (fast)
	$(SSH) 'sudo ~/dyverz-os/scripts/apply-overlay.sh && sudo dconf update'
aur: sync        ## build AUR packages into ~/dyverz-repo on the VM
	$(SSH) '~/dyverz-os/scripts/build-aur-repo.sh'
iso: sync        ## build the ISO on the VM (ED=windows|mac|ubuntu|fedora|mint|all)
	$(SSH) 'sudo ~/dyverz-os/scripts/build-iso.sh $(ED)'
fetch:           ## pull built ISOs back to the laptop
	rsync -a --progress -e "ssh -p $(PORT)" $(VM):dyverz-out/ ./out/
help:
	@grep -E '^[a-z]+:.*##' Makefile | sed 's/:.*##/ —/'
