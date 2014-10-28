#! /usr/bin/python

import greatcircle, sys, generic_plot, numpy, scipy, pylab

def process_iata_file(input_file):
  unknown = []
  f = open(input_file, 'r')
  lines = f.readlines()
  f.close()
  list_dist = {'o': [], 'd': [], 'iata': [], 'gc': []}
  for line in lines:
    line = line.rstrip('\n')
    fields = line.split(' ')
    flag_ok = False
    #try:
    o = fields[0]
    d = fields[1]
    iata_dist = float(fields[2][-12:-2])
    gc_dist = greatcircle.dist_two_airports(o, d)
    if gc_dist['km'] == -1:
      for x in gc_dist['unknown']:
        if not x in unknown: unknown.append(x)
    else:
      flag_ok = True
    #except:
      #print "strange line:", line
    if flag_ok:
      list_dist['iata'].append(iata_dist)
      list_dist['gc'].append(gc_dist['km'])
      list_dist['o'].append(o)
      list_dist['d'].append(d)
  unknown.sort()
  return list_dist, unknown

def plot_gc_iata(input_file, output_file):
  a = numpy.loadtxt(input_file, delimiter=',', comments='#')
  #list_x = [(a[i,0],) for i in range(scipy.size(a, axis=0))]
  #list_y = [(a[i,1],) for i in range(scipy.size(a, axis=0))]
  #list_format = ['.b' for i in range(scipy.size(a, axis=0))]
  
  list_y = (a[:,0],)
  list_x = (a[:,1],)
  list_s = (1,)
  list_color = ('b',)
  list_marker = ('o',)
  ylabel = 'IATA "distance"'
  xlabel = 'great circle distance (km)'
  xlim = [0, 20000]
  ylim = xlim
  axes = [0.08, 0.08, 0.88, 0.88]
  
  generic_plot.scatter_and_format(list_x, list_y, list_s=list_s, list_color=list_color, list_marker=list_marker, xlabel=xlabel, ylabel=ylabel, xticks=None, yticks=None, format_xticks=None, format_yticks=None, axes=axes, figure_figsize=None, xlim=xlim, ylim=ylim, fontsize=10, title=None)
  pylab.plot(xlim, ylim, 'r-')
  pylab.xlim(xlim)
  pylab.ylim(ylim)
  generic_plot.exportplot(output_file, h=1000, w=1000)
  
def main():
  input_iata = 'iata.txt'
  iata_gc_file = 'iata_gc.txt'
  iata_gc_od_file = 'iata_gc_od.txt'
  gc_iata_png = 'iata_gc_plot.png'
  
  # determine dist
  list_dist, unknown = process_iata_file(input_iata)
  f = open(iata_gc_file, 'w')
  f_od = open(iata_gc_od_file, 'w')
  for iata, gc, o, d in zip(list_dist['iata'], list_dist['gc'], list_dist['o'], list_dist['d']):
    f_od.write('%.0f,%.0f,%s,%s\n' % (iata, gc, o, d))
    f.write('%.0f,%.0f\n' % (iata, gc))
  f.close()
  f_od.close()
  for x in unknown: print x
  
  # plot comp
  plot_gc_iata(iata_gc_file, gc_iata_png)
  
if __name__ == "__main__":
    main()

# outliers
# awk -F ',' '{if (($2>1000) && ($1<800)) {print $0}}' iata_gc_od.txt
# awk -F ',' '{if (($2>1000) && ($1<800)) {print $3}}' iata_gc_od.txt | sort | uniq -c | sort
  
