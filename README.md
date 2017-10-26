# media-importer
Smart import of media files from portable devices to the users windows photo library.
**Experimental** Not yet ready

Smart import of media files from 
  * phones, connected via USB (MTD device)
  * SD cards from cameras
  * Image folders on Windows storage devices (USB Sticks, USB Harddrives, internal drives)

During import, media files are sorted into a local folder structure below Windows picture 
library (C:/Users/"user"/Pictures) based on year and month, e.g. C:/Uses/ralf/Pictures/2017/10

Media Importer is aware of media files, that are already present in the target folders. It also 
skips media files, that shall be ignored.

## Integration in Windows Explorer
Media Importer provides two context menu entries in Windows Explorer.
  * **MarkDeleted** moves a media file to a ".deleted" folder and enters the file in the "markded-for-deletion.csv" 
    index for deleted files.
  * **ImportMedia** starts the import of media files on the selected folder

## Setup
  * In the Windows Registry files you have to adapt the path to the called scripts.
  * Set the environment variable **media_importer_data** to a directory, where MediaImporter stores the index files for deleted files and the fotoindex.


## Erweiterungen:
  * Überschreiben bzw. Neukopieren aller Medien
  * Mit Adnroid testen
  * Folders vorgeben

  ## Extensions
  mp3, jpg, mov mp4

  ## Target Folder
  The program requires a parameter "startPath" when it is called. For an iPhone, this is the
  device name as it is shown in Windows Explorer followed by the "Internal Storage" folder.

**Example**
  <code>./media-importer.ps1 "iPhone von Ralf\Internal Storage"</code>


