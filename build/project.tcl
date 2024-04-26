set projName xdma_ddr	
set part xc7z100ffg900-2	
set top xdma_ddr_wrapper	
set tb_top tb_ddr_data_sim

proc run_create {} {
    global projName
    global part
    global top
    global tb_top

    set outputDir ./$projName			

    file mkdir $outputDir

    create_project $projName $outputDir -part $part -force		

    set projDir [get_property directory [current_project]]

    add_files -fileset [current_fileset] -force -norecurse {
        ../src/xdma_ddr_wrapper.v
    }

    add_files -fileset [current_fileset -constrset] -force -norecurse {
        ../src/pcie.xdc
    }

    source {../bd/xdma_ddr.tcl}

    set_property top $top [current_fileset]
    set_property generic DEBUG=TRUE [current_fileset]

    set_property AUTO_INCREMENTAL_CHECKPOINT 1 [current_run -implementation]

    update_compile_order
}

proc run_build {} {         
    upgrade_ip [get_ips]

    # Synthesis
    launch_runs -jobs 12 [current_run -synthesis]
    wait_on_run [current_run -synthesis]

    # Implementation
    launch_runs -jobs 12 [current_run -implementation] -to_step write_bitstream
    wait_on_run [current_run -implementation]
}