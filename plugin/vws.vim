
let g:VWS#Loaded = 1
let g:VWS#Marker    = get(g:,'VWS#Marker','#')
let g:VWS#Directory = get(g:,'VWS#Directory','./.vim/vws')

function! VWSLoadWorkSpace(VWSFileName)

    let FileContentArray = readfile(g:VWS#Directory.'/'. a:VWSFileName)

    let WorkSpace = []
    let TabNames = []

    for line in FileContentArray
        if line =~# g:VWS#Marker.'.*'
            let str = split(line,g:VWS#Marker.'\s*')[0]
            call add(TabNames,substitute(str,'\s*$',"",""))
            call add(WorkSpace,[])
        else
            call add(WorkSpace[-1+len(WorkSpace)],line)
        endif
    endfor

    for i in range(len(WorkSpace))
        if i == 0
            for j in range(len(WorkSpace[i]))
                if j == 0
                    exec 'edit ' . WorkSpace[i][j]
                else
                    exec 'vsplit ' . WorkSpace[i][j]
                endif
            endfor
        else
            for j in range(len(WorkSpace[i]))
                if j == 0
                    exec 'tabnew ' . WorkSpace[i][j]
                else
                    exec 'vsplit ' . WorkSpace[i][j]
                endif
            endfor
        endif

        if exists('g:loaded_taboo')
            exec ':TabooRename '.TabNames[i]
        endif

    endfor

    exec ':tabnext 1'

endfu

function! VWSSaveWorkSpace(VWSFileName)
    let NumberOfTabs = tabpagenr('$')
    let LastTab = tabpagenr()
    let FileList = []

    for i in range(1,NumberOfTabs)
        exec 'tabn '.i
        let marker = g:VWS#Marker

        if exists('t:taboo_tab_name')
            let marker = marker . ' ' . t:taboo_tab_name
        else
            let marker = marker . ' ' . bufname("")
        endif

        call add(FileList,marker)

        let NumberOfWindows = winnr('$')

        for j in range(1,NumberOfWindows)
            call add(FileList,bufname(winbufnr(j)))
        endfor

    endfor

    call system('mkdir '.g:VWS#Directory)
    call writefile(FileList,g:VWS#Directory.'/'. a:VWSFileName)
endfu

function! VWSListLayouts(A,L,P)
    return system("ls ".g:VWS#Directory)
endfu

command! -complete=custom,VWSListLayouts -nargs=? VWSSaveWorkSpace call VWSSaveWorkSpace("<args>")
command! -complete=custom,VWSListLayouts -nargs=? VWSLoadWorkSpace call VWSLoadWorkSpace("<args>")
