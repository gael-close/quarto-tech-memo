#%%
from pathlib import Path
import os
from invoke import task, Context

@task
def test(c, gh=False, format='all', ieee=True):
    # Clean up and instantiate example from Github or local
    # Install local extension if appropriate
    # Else rely on quarto-tech-memo script which will install github extension on the fly 
    c.run(f"""
        rm -fr new-dir/*; 
        cookiecutter -f {'gh:gael-close/quarto-tech-memo' if gh else '.'} --no-input  
        cd new-dir;
        {'' if gh else 'quarto add ../ --no-prompt'}
""")
    
    if format=='all': 
        formats = ['memo1', 'memo2', 'poster', 'slides']
        if ieee:
            formats.append('ieee')
    else:
        formats = [format]
    
    for fmt in formats:
    #for format in ['poster-typst']: 
        c.run(f'''
            cd new-dir;
            quarto-tech-memo new-tech-memo.md --to {fmt};
            magick -density 150 new-tech-memo.pdf -quality 90 -background white -alpha remove thumbnail-{fmt}.png;
            cp new-tech-memo.pdf new-tech-memo-{fmt}.pdf;
            ''')
    
@task
def save(c):
    c.run(f'''
        
        (cd new-dir; cp new-tech-memo-*.pdf ../examples;);
        (cd examples; resvg --dpi 300 collage.svg collage.png;);  
        ''')

import timeit
@task
def conversion_time(c, format='memo1-typst'):
    f = lambda: c.run(f"cd new-dir; quarto render new-tech-memo.md --to {format};")
    N = 4
    elapsed = timeit.timeit(f, number=N)
    print(f"Average time: {elapsed/N} seconds")

#%%
@task 
def dev(c):
    c.run(f'''
        cd ~/Downloads/new-dir;;
        ''')
    

c = Context()
#dev(c)

# %%
