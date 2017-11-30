##
## This class is intended to take care for downloading and
## unpacking of the rough stuff(data files,...) for this
## project.
##
GetRoughData <- setRefClass("GetRoughData",
                       fields = list(fileUrl = "character",
                                     fileName = "character",
                                     fileDoesExist = "logical")
                       ,
                       methods = list(
                           #'
                           #' Get the full file name from the rough file URL.
                           #'
                           #' @return
                           #'
                           roughFileName = function(){
                               fileName <<- basename(URLdecode(fileUrl))
                           },
                           #'
                           #' Check if the 'fileName' does exist.
                           #'
                           #' @param fileName 
                           #'
                           #' @return
                           #'
                           roughFileDoesExist = function(fileName = fileName){
                               return(ifelse(TRUE == file.exists(fileName),
                                             fileDoesExist <<- TRUE,
                                             fileDoesExist <<- FALSE))
                           },
                           #'
                           #' Download the rough stuff.
                           #'
                           #' @param fileUrl 
                           #'
                           #' @return
                           #'
                           roughFileDownload = function(fileUrl = fileUrl){
                               download.file(url = fileUrl, destfile = fileName)
                           },
                           #'
                           #' Unpack('unzip') the downloaded rough stuff.
                           #'
                           #' @param fileName 
                           #' @param packType 
                           #'
                           #' @return
                           #'
                           roughFileUnPack = function(fileName = fileName, packType = "zip"){
                               if("zip" == tolower(packType)){
                                   unzip(fileName)
                               }
                           }
                       )
)

