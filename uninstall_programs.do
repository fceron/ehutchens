



program uninstall_ehutchens
    local path = c(sysdir_plus) + "e/ehutchens.ado"
    if (fileexists("`path'")) {
        display "Uninstalling ehutchens..."
        erase "`path'"
        local helpfile = c(sysdir_plus) + "e/ehutchens.sthlp"
        if (fileexists("`helpfile'")) {
            erase "`helpfile'"
        }
        display "ehutchens package has been successfully uninstalled."
    }
    else {
        display as error "ehutchens package not found in the PLUS directory."
    }
end




********************************************************************************



program uninstall_hu_int
    local path = c(sysdir_plus) + "h/hu_int.ado"
    if (fileexists("`path'")) {
        display "Uninstalling hu_int..."
        erase "`path'"
        
        }
        display "hu_int package has been successfully uninstalled."
    
    else {
        display as error "hu_int package not found in the PLUS directory."
    }
end




