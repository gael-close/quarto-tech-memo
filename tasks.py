#%%
from pathlib import Path
import os
from invoke import task, Context

@task
def test(c, gh=False, format='all'):
    c.run(f'''
        cd ~/Downloads; rm -fr new-dir/*; 
        cookiecutter -f {'gh:gael-close' if gh else '$B4'}/quarto-tech-memo {'--no-input' if not gh else ''} ; cd new-dir;''')
    
    if format=='all': 
        formats = ['memo1-typst', 'memo2-typst', 'poster-typst', 'ieee-pdf', 'slides-typst']
    else:
        formats = [format]
    for fmt in formats:
    #for format in ['poster-typst']: 
        c.run(f'''
            cd ~/Downloads/new-dir;
            quarto render new-tech-memo.md --to {fmt}; 
            #zathura new-tech-memo.pdf;
            magick -density 150 new-tech-memo.pdf -quality 90 -background white -alpha remove thumbnail-{fmt}.png;
            cp new-tech-memo.pdf new-tech-memo-{fmt}.pdf;
            ''')
    
@task
def save(c):
    c.run(f'''
        
        (cd ~/Downloads/new-dir; cp new-tech-memo-*.pdf $B4/quarto-tech-memo/examples;);
        (cd examples; resvg --dpi 300 collage.svg collage.png;);  
        ''')


#%%
@task 
def dev(c):
    c.run(f'''
        cd ~/Downloads/new-dir;;
        ''')
    

c = Context()
#dev(c)

# %%
