# TC:   https://github.com/fgerling/bdd-poc
# This is a basic test for kured (no PR or BSC provided)

Feature: Check if reboot triggered

Scenario: Checking if reboot triggered on one node
    Given "skuba" exist in gopath
    And VARIABLE "imba-cluster" I get from CONFIG
    When I run "skuba cluster status" in VAR:"imba-cluster" directory
    Then the output contains "master" and "worker"
    When I run "kubectl get all --namespace=kube-system"
    Then the output contains "cilium" and "dex"

    When I run "kubectl get daemonset kured -o yaml -n kube-system"
    And I insert in OUTPUT "- --period=30s" and save it to kurednew.yaml
    And I run "kubectl apply -f kurednew.yaml"
    Then the output contains "configured"
    And wait "30 seconds"
    When I run "kubectl get pods --namespace=kube-system"
    When VARIABLE "privileged-pods" equals ContainersFROMOutput "kured-"
    And VARIABLES "commandchecks" equals "kubectl describe pod -n kube-system " plus VAR:"privileged-pods"
    And I run VARS:"commandchecks" and IPSFromOutput
    And I run SSHCMD "sudo touch /var/run/reboot-required" on MASTER
    And wait "140 seconds"
    And I run SSHCMD "sudo crictl ps" on MASTER
    Then the output contains "seconds" or "a minute"