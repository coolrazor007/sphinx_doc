
[builder]
%{ for ip in builderIP ~}
ubuntu@${ip}
%{ endfor ~}