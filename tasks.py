#%%
from pathlib import Path
import os
from invoke import task, Context

@task
def test(c, gh=False):
    c.run(f'''
        cd ~/Downloads; rm -fr new-dir/*; 
        cookiecutter -f {'gh:gael-close' if gh else '$B4'}/quarto-tech-memo {'--no-input' if not gh else ''} ; cd new-dir;''')
    
    for format in ['memo1-typst', 'memo2-typst', 'poster-typst', 'ieee-pdf']:
    #for format in ['poster-typst']: 
        c.run(f'''
            cd ~/Downloads/new-dir;
            quarto render new-tech-memo.md --to {format}; 
            #zathura new-tech-memo.pdf;
            convert -density 150 new-tech-memo.pdf -quality 90 -background white -alpha remove thumbnail-{format}.png;
            cp thumbnail-{format}.png $B4/quarto-tech-memo/thumbnails 
            ''')
    

#%%
@task 
def dev(c):
    c.run(f'''
        cd ~/Downloads/new-dir;
        convert -density 150 new-tech-memo.pdf -quality 90 -background white -alpha remove thumbnail.png;''')
    


c = Context()
dev(c)

# %%
