@include "/home/swatcher/rkn_mikrotik_addr_list/lib_netaddr.awk"

function sanitize(ip) {
    split(ip, slice, ".")
    return slice[1]/1 "." slice[2]/1 "." slice[3]/1 "." slice[4]/1
}

function snbounds(to,i) {
    sn_min=grp[1]
    sn_max=grp[to]

    for(sn_mask=32; sn_mask && sn_min != sn_max; sn_mask--) {
        sn_min = rshift(sn_min,1)
        sn_max = rshift(sn_max,1)
    }

    for(i=32; i>sn_mask; i--) {
        sn_min = lshift(sn_min,1) 
        sn_max = lshift(sn_max,1) + 1
    }
}

function grpstd(val, tot, cnt, mean, sqtot) {
    cnt = length(grp)
    snbounds(cnt)
    tot = sn_min + sn_max
    cnt += 2
    for(val in grp) tot=tot + grp[val]
    mean = tot / cnt
    sqtot = (sn_min - mean) * (sn_min - mean) + \
            (sn_max - mean) * (sn_max - mean)
    for(val in grp) {
       sqtot = sqtot + (grp[val] - mean) * (grp[val] - mean)
    }
    return sqrt(sqtot / cnt)
}

BEGIN { limit=750 }

{ k[NR]=ip2dec(sanitize($1)) }

END {
    n=asort(k)

    print "/ip firewall address-list"

    for(idx=1; idx <= n ; idx++) {
       grp[++have]=k[idx]
       # print dec2ip(grp[have]) " std: " grpstd()
       if(grpstd() > limit) {
          snbounds(length(grp)-1)
          # print "\nSubnet from " dec2ip(grp[1]) " to " dec2ip(grp[have-1]) " " have - 1 " IP(s)"
          print "add address=" dec2ip(sn_min) "/" sn_mask " list=rkn"
          have=split(grp[have], grp)
       }
    }
    if (have) {
          snbounds(length(grp))
          # print "\nSubnet from " dec2ip(grp[1]) " to " dec2ip(grp[have]) " " have " IP(s)"
          print "add address=" dec2ip(sn_min) "/" sn_mask " list=rkn"
    }
}
