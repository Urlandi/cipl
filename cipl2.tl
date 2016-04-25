#!/usr/bin/tclsh8.5

set exip {^(2(5[0-5]|[0-4]\d)|1\d{2}|[1-9]\d{0,1})(\.(2(5[0-5]|[0-4]\d)|1\d{2}|[1-9]\d|\d)){3}$}
set exdg {^(0?|([1-9]\d{0,5}))$}

if {$argc == 0 || $argc > 2} then {
        puts "cipl.tl - Выводит список IP адресов начиная с заданного"
        puts "Использование: cipl.tl <start IP> \[<count>|<finish IP>\]"
	puts "Аргументы: <start IP>  - IPv4 адрес меньший либо равный <finish IP>"
	puts "\t   <finish IP> - IPv4 адрес"
	puts "\t   <count>     - число от 0 до 999999"
} else {	
	set startip [lindex $argv 0]
	set countip [lindex $argv 1]
	set getcountip $countip
	if {[regexp $exip $startip]} then {
		set octsip [split $startip {.}]
		if {[regexp $exip $countip]} then {
			set octfip [split $countip {.}]
			set nfip [expr ([lindex $octfip 0] * 0x1000000) + ([lindex $octfip 1] * 0x10000)\
 				+ ([lindex $octfip 2] * 0x100) + ([lindex $octfip 3])]
			set nsip [expr ([lindex $octsip 0] * 0x1000000) + ([lindex $octsip 1] * 0x10000)\
 				+ ([lindex $octsip 2] * 0x100) + ([lindex $octsip 3])]	
			if {$nfip >= $nsip} then {set countip [expr $nfip - $nsip]}
		}
		if {[regexp $exdg $countip]} then {
			puts $startip
			for {set i 0} {$i<$countip} {incr i 1} {
				set octsip [lreplace $octsip {3} {3} [expr [lindex $octsip {3}] + 1]] 
				for {set j 3} {$j>=0} {incr j -1} {
					if {[lindex $octsip $j] > 255 && $j > 0} then {
						set sj [expr $j - 1]
						set octsip [lreplace $octsip $j $j {0}]
						set octsip [lreplace $octsip $sj $sj [expr [lindex $octsip $sj] + 1]]
					}
				}
				set oip [join $octsip {.}]
				if {[regexp $exip $oip]} then {
                                        puts $oip
                                } else {
					puts "СТОП: Достигнут максимальный возможный адрес"
					exit 3
				}
			}
		} else {
			puts "Неверно задан второй аргумент \"$getcountip\""			
		}
	} else {
		puts "Неверно задан начальный IP адрес \"$startip\""
	}
}

