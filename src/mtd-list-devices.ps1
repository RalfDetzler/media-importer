# List Devices for NameSpace 0x11
# ===============================
$folder = (new-object -com shell.application).NameSpace(0x11)

$items = $folder.Items()
for ($i= 0; $i -lt $items.Count; $i++) {
    write-output ($items.Item($i).Name)
}
