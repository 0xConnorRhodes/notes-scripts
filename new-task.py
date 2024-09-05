#region config
import os
import socket
import subprocess
from jinja2 import Environment, FileSystemLoader
from pyfzf.pyfzf import FzfPrompt
fzf = FzfPrompt()

notes_dir = os.path.expanduser('~/notes')

hostname = socket.gethostname()
termux_test = os.getenv('TERMUX_APP_PID')

if hostname == 'devct':
    platform = 'linux'
elif int(termux_test) > 0:
    platform = 'android'
#endregion

#region functions
def split_task_sections(task_string):
    """
    split the input string into component parts
    """
    task_info_dict = {
        "task_name": None,
        "start_date": False,
        "due_date": False,
        "tag_list": []
    }

    task_string = task_string.strip()

    indices = {
        "task_name": 0,
        "start_date": task_string.find(' s '),
        "due_date": task_string.find(' d '),
        "tag_list": task_string.find(' t ')
    }

    present_indices = {key: value for key, value in indices.items() if value != -1}
    sorted_indices = sorted(present_indices.items(), key=lambda item: item[1])

    si_length = len(sorted_indices)
    for i in range(si_length):
        attribute_name = sorted_indices[i][0]
        start_index = sorted_indices[i][1]
        if i == si_length-1:
            end_index = len(task_string)
        else:
            end_index = sorted_indices[i+1][1]

        task_info_dict[attribute_name] = task_string[start_index:end_index]
    
    if task_info_dict['start_date']:
        task_info_dict['start_date'] = task_info_dict['start_date'].replace(' s ', '')
    if task_info_dict['due_date']:
        task_info_dict['due_date'] = task_info_dict['due_date'].replace(' d ', '')
    if task_info_dict['tag_list']:
        task_info_dict['tag_list'] = task_info_dict['tag_list'].replace(' t ', '').split()
    
    return task_info_dict

def clean_render(content):
    new_content = content
    lines = content.splitlines()
    if lines[0] == '':
        lines = lines[1:]
    dash_count = 0
    new_lines = []
    for line in lines:
        if dash_count > 0 and dash_count < 2:
            if line.strip() == '':
                continue
        if line.strip() == '---':
            dash_count += 1

        new_lines.append(line)
    new_content = '\n'.join(new_lines)
    return new_content
#endregion

task_input = input('task: ')

if not task_input:
    print('no task')
    exit(0)

task_info = split_task_sections(task_input) # TODO: add, new, vars as you update split_task_sections()

if task_info['start_date']:
    start_date = task_info['start_date']
    # screen out start dates in the form 240529
    if start_date.isdigit() and len(start_date) < 4:
        # TODO: add the start_date value to the value of $today and set that as start_date in the proper format
        pass

base_dir = os.path.dirname(os.path.abspath(__file__))
template_dir = os.path.join(base_dir, 'templates')
env = Environment(loader=FileSystemLoader(template_dir))
template = env.get_template('task.md.j2')

rendered_content = template.render(task_info)

rendered_content = clean_render(rendered_content)

filename = f"tk_{task_info['task_name']}.md"
task_file_path = os.path.join(notes_dir, filename)

print(rendered_content)

with open(task_file_path, 'w') as file:
    file.write(rendered_content)

if platform == 'linux':
    subprocess.run(f'nvim +normal!Go +startinsert "{task_file_path}"', shell=True)
elif platform == 'android':
    subprocess.run(f'termux-open "{task_file_path}"', shell=True)