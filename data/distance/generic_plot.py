#! /usr/bin/python

import pylab

def exportplot(filename, w=600.0, h=400.0, dpi=100.0, fig=pylab.gcf()):
	if filename == 'out':
		pylab.show()
	else:
		inches = pylab.array([w, h])/dpi
		fig.set_size_inches(inches[0], inches[1])
		fig.savefig(filename, dpi=dpi)

def scatter_and_format(list_x, list_y, list_color=None, list_s=None, list_marker=None, xlabel=None, ylabel=None, xticks=None, yticks=None, format_xticks=None, format_yticks=None, axes=None, figure_figsize=None, xlim=None, ylim=None, fontsize=10, title=None, plot_date=False):
	# figure
	if not figure_figsize is None: pylab.figure(1, figsize=figure_figsize)
	
	# axes
	if axes is None:
		ax = pylab.axes()
	else:
		ax = pylab.axes(axes)
 
	# plot
	n_plots = len(list_y)
	for i in range(n_plots):
		x, y = list_x[i], list_y[i]
		str_scatter = "this_p = pylab.scatter(x, y"
		if not list_s is None: str_scatter += ', s=%s' % (list_s[i],)
		if not list_marker is None: str_scatter += ", marker='%s'" % (list_marker[i],)
		str_scatter += ')'
		exec(str_scatter)
		if not list_color is None: pylab.setp(this_p, color=list_color[i])
	
	# axis labels
	if not xlabel is None: pylab.xlabel(xlabel, fontsize=fontsize)
	if not ylabel is None: pylab.ylabel(ylabel, fontsize=fontsize)
	
	# ticks
	ax.xaxis.tick_bottom()
	ax.yaxis.tick_left()
	if not xticks is None: pylab.xticks(xticks['ticks'], xticks['labels'])
	if not yticks is None: pylab.yticks(yticks['ticks'], yticks['labels'])
	if plot_date:
		x_rotation = 45
	else:
		x_rotation = 0
	pylab.setp(ax.get_xticklabels(), 'rotation', x_rotation, fontsize=fontsize)
	pylab.setp(ax.get_yticklabels(), 'rotation', 0, fontsize=fontsize)
	if not format_xticks is None:
		if plot_date:
			fmt = pylab.DateFormatter(format_xticks)
		else:
			fmt = pylab.Formatter(format_xticks)
		ax.xaxis.set_major_formatter(fmt)
	if not format_yticks is None:
		ax.yaxis.set_major_formatter(pylab.Formatter(format_yticks))

	# title
	if not title is None: pylab.title(title, fontsize=fontsize)
	
	# limits
	if not xlim is None:
		if plot_date: xlim = [pylab.date2num(a) for a in xlim]
		pylab.xlim(xlim)
	if not ylim is None: pylab.ylim(ylim)
	
def plot_and_format(list_x, list_y, list_color=None, list_format=None, xlabel=None, ylabel=None, xticks=None, yticks=None, format_xticks=None, format_yticks=None, legend=None, loc_legend='best', axes=None, figure_figsize=None, xlim=None, ylim=None, fontsize=10, title=None, plot_date=False):
	# figure
	if not figure_figsize is None: pylab.figure(1, figsize=figure_figsize)
	
	# axes
	if axes is None:
		ax = pylab.axes()
	else:
		ax = pylab.axes(axes)
 
	# plot
	p = []
	n_plots = len(list_y)
	for i in range(n_plots):
		x, y = list_x[i], list_y[i]
		if plot_date:
			x_num = pylab.date2num(x)
			if list_format is None:
				this_p = pylab.plot_date(x_num, y)
			else:
				this_p = pylab.plot_date(x_num, y, list_format[i])
		else:
			this_p = pylab.plot(x, y)	
			if list_format is None:
				this_p = pylab.plot(x, y)
			else:
				this_p = pylab.plot(x, y, list_format[i])
		if not list_color is None: pylab.setp(this_p, color=list_color[i])
		this_p.append(p)
		
	# axis labels
	if not xlabel is None: pylab.xlabel(xlabel, fontsize=fontsize)
	if not ylabel is None: pylab.ylabel(ylabel, fontsize=fontsize)
	
	# legend
	if not legend is None:
		pylab.legend(p, legend, loc=loc_legend)
		ltext = pylab.gca().get_legend().get_texts()
		pylab.setp(ltext[0], fontsize = fontsize)
	
	# ticks
	ax.xaxis.tick_bottom()
	ax.yaxis.tick_left()
	if not xticks is None: pylab.xticks(xticks['ticks'], xticks['labels'])
	if not yticks is None: pylab.yticks(yticks['ticks'], yticks['labels'])
	if plot_date:
		x_rotation = 45
	else:
		x_rotation = 0
	pylab.setp(ax.get_xticklabels(), 'rotation', x_rotation, fontsize=fontsize)
	pylab.setp(ax.get_yticklabels(), 'rotation', 0, fontsize=fontsize)
	if not format_xticks is None:
		if plot_date:
			fmt = pylab.DateFormatter(format_xticks)
		else:
			fmt = pylab.Formatter(format_xticks)
		ax.xaxis.set_major_formatter(fmt)
	if not format_yticks is None:
		ax.yaxis.set_major_formatter(pylab.Formatter(format_yticks))

	# title
	if not title is None: pylab.title(title, fontsize=fontsize)
	
	# limits
	if not xlim is None:
		if plot_date: xlim = [pylab.date2num(a) for a in xlim]
		pylab.xlim(xlim)
	if not ylim is None: pylab.ylim(ylim)

def tests():
	x = pylab.arange(0.0, 2*pylab.pi, 0.01)
	list_y = (pylab.sin(x),pylab.sin(2*x))
	plot_and_format((x,), (list_y[0],))
	exportplot('test/test1_one_curve.png')
	pylab.clf()
	list_x = (x, x)
	plot_and_format(list_x, list_y)
	exportplot('test/test2_two_curves.png')
	pylab.clf()
	list_format = ('k-', 'r--')
	plot_and_format(list_x, list_y, list_format=list_format)
	exportplot('test/test3_two_curves_formatting.png')
	pylab.clf()
	plot_and_format(list_x, list_y, list_format=list_format, xlabel='hello x axis')
	exportplot('test/test4_two_curves_formatting_xlab.png')
	pylab.clf()
	plot_and_format(list_x, list_y, list_format=list_format, legend=['sin($x$)', 'sin($2x$)'])
	exportplot('test/test5_two_curves_formatting_legend.png')
	pylab.clf()
	plot_and_format(list_x, list_y, list_format=list_format, xticks={'ticks': [0, pylab.pi, 2*pylab.pi], 'labels':['0', '$\pi$', '$2\pi$']})
	exportplot('test/test6_two_curves_formatting_xticks.png')
	pylab.clf()
	plot_and_format(list_x, list_y, list_format=list_format, xticks={'ticks': [0, pylab.pi, 2*pylab.pi], 'labels':['0', '$\pi$', '$2\pi$']}, xlim=[0,2*pylab.pi])
	exportplot('test/test7_two_curves_formatting_xticks_xlim.png')
	pylab.clf()

def main():
	import numpy, scipy
	a = numpy.loadtxt('log_times.txt', dtype=float, delimiter=',')
	x = a[:,0]
	list_y = (a[:,3]/a[:,2],)
	plot_and_format((x,), list_y, list_format = ('k.',), xlabel='instance (file)', ylabel='time for shaoril1 / time for orilnx02')
	exportplot('log_times.png')
	tests()

if __name__ == "__main__":
    main()