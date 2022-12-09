#Google API: https://console.cloud.google.com/apis/api/youtube.googleapis.com/metrics?hl=de&project=my-project-1575220562473


# Uncomment this section to get URLs from a web page
#--------------------------Get URLs via Web----------------------------------

#$URLArray = 
#'WRITE YOUR URL HERE',
#'WRITE YOUR URL HERE'


#$YoutubeStrings = $null
#foreach ($Url in $URLArray) {
#$YoutubeStrings += (Invoke-WebRequest -Uri $Url).Links.Href 
#}

#----------------------------------------------------------------------------



#---------------Get URLs via .html file in folder recursive------------------

# Use the Get-ChildItem cmdlet to find HTML files in a specific folder
$Path = "WRITE YOUR PATH HERE" #< Write your path, example: "D:\Test"
$YoutubeStrings = Get-ChildItem $Path -Filter *.html -Recurse | Select-String 'youtu'

#----------------------------------------------------------------------------

# Define a function to check if a YouTube video is available
function CheckIfYoutubeVideoIsAvailable ($YoutubeStrings) {
$MissingYoutubeVideos = $null

    #Write-Host $YoutubeStrings | Select-String 'youtu'

    foreach ($string in $YoutubeStrings) {

        #Write-Host $string       

        $FilterUrlBool = $string -match 'watch|.be/'
        if ($FilterUrlBool) {

            # If it's a YouTube URL, extract the whole URL and the YouTube ID
            $filterYoutubeUrl = $string -match 'https(.*?)youtu([^"]*)' #Filters every youtube URL inside quotation marks
            if ($filterYoutubeUrl) {
                $foundWholeUrl = $Matches[0]
                #Write-Host $foundWholeUrl

                $foundYoutubeIdMatch = $foundWholeUrl -match '((?<=be\/)|(?<=watch\?v=)|(?<=&v=))([^?]*)' #Filters the Youtub ID, everythink after "be/","watch?" until "?" or end of string
                $foundYoutubeId = $Matches[0]
                #Write-Host $foundYoutubeId

                # Use the YouTube Data API v3 to check if the video is available
                $gooleApiRequestString = "https://www.googleapis.com/youtube/v3/videos?part=id&id=" + $foundYoutubeId + "&key={YOUT GOOGLE YouTube Data API v3 Key}" #Yout need a YouTube Data API v3 Key: https://youtu.be/QY8dhl1EQfI
                $response = Invoke-RestMethod -Uri $gooleApiRequestString       
                       
                # If the video is not available, add the URL to the list of missing videos
                if ($response.pageInfo.totalResults -eq 0) {
                    Write-Host $foundWholeUrl
                    $MissingYoutubeVideos += $foundWholeUrl + "`r`n"
                }

            }       

        }

    }

    # If there are missing videos, return the list of URLs
    if($MissingYoutubeVideos -ne $null){
    return $MissingYoutubeVideos
    }

}




#-----Main-------
$MissingYoutubeVideos = CheckIfYoutubeVideoIsAvailable($YoutubeStrings)

#Writes a textfile with the missing youtube URLs
if($MissingYoutubeVideos -ne $null){
$MissingYoutubeVideos | Out-File -FilePath "C:\MissingYoutubeVideo.txt"
}