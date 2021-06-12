#!/bin/bash
y=0;
for i in {5000..6000}
   do
      ((y++));
      iptables -t nat -A PREROUTING -p tcp --dport $i -j DNAT --to-destination 10.10.24.2:$y;
done
