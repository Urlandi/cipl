#!/usr/bin/tclsh8.5

set exip {^(2(5[0-5]|[0-4]\d)|1\d{2}|[1-9]\d{0,1})(\.(2(5[0-5]|[0-4]\d)|1\d{2}|[1-9]\d|\d)){3}$}
set exdg {^-?(0?|([1-9]\d*))$}
set maxip {0xFFFFFFFF}
set minip {0xFFFFFF}

if {$argc == 0 || $argc > 2} then {
        puts "cipl.tl - Выводит список IP адресов начиная с заданного"
        puts "Использование: cipl.tl <start IP> \[<count>|<finish IP>\]"
	puts "Аргументы: <start IP>  - IPv4 адрес"
	puts "\t   <finish IP> - IPv4 адрес"
	puts "\t   <count>     - число элементов списка, \"-\" в обратном порядке"
} else {	
	set startip [lindex $argv 0]
	if {![string length [set finiship [lindex $argv 1]]]} then {set finiship {0}}	
	if {[regexp $exip $startip]} then {
		set octsip [split $startip {.}]
		set nsip [expr ([lindex $octsip 0] * 0x1000000) + ([lindex $octsip 1] * 0x10000)\
 			+ ([lindex $octsip 2] * 0x100) + ([lindex $octsip 3])]
		if {[regexp $exip $finiship]} then {
			set octfip [split $finiship {.}]
			set nfip [expr ([lindex $octfip 0] * 0x1000000) + ([lindex $octfip 1] * 0x10000)\
 				+ ([lindex $octfip 2] * 0x100) + ([lindex $octfip 3])]			
		} elseif {[regexp $exdg $finiship] && [expr abs($finiship)] < $maxip} then {
			set nfip [expr $nsip + $finiship]
		} else {
			puts "Неверно задан второй аргумент \"$finiship\""
			exit 5
		}		
		if {$nfip > $minip && $nfip < $maxip} then {
			if {[set d [expr $nfip >= $nsip]]} then {set di {1}} else {set di {-1}}
			for {set i $nsip} {($i<=$nfip && $d) || ($i>=$nfip && !$d)} {incr i $di} {
				set octip [list [expr ($i & 0xFF000000) >> 24] [expr ($i & 0xFF0000) >> 16]\
 					[expr ($i & 0xFF00) >> 8] [expr ($i & 0xFF)]]				
				puts [join $octip {.}]				
			}
		} else {
			puts "Последний IP списка выходит за границы допустимого диапазона"
			exit 3
		}
	} else {
		puts "Неверно задан начальный IP адрес \"$startip\""
	}
}

