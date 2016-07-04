Deploy 'Deploy Wunderlist Module script' {
    By Filesystem {
        FromSource 'C:\users\Stefan\Documents\GitHub\Wunderlist2'
        To "$($env:PSModulePath.split(';')[0])\Wunderlist"
        Tagged Prod, Module
        WithOptions @{
            Mirror = $false
        }
    }
}