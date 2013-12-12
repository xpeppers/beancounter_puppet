define download_file(
        $site="",
        $cwd="",
        $unless="/usr/bin/test 1 = 1", #sicuramente vero
        $creates="",
        $require="",
        $before="") {                                                                                         

    exec { $name:                                                                                                                     
        command => "/usr/bin/wget ${site}/${name}",                                                         
        cwd => $cwd,
        creates => "${cwd}/${name}",                                                              
        require => $require,
        before => $before,  
        logoutput => "on_failure",
        timeout => 10000,
        unless => $unless                                                                                                       
    }

}