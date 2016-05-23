function plotAsTikz(fileName)

%% Simple function to save the current figure as a Tikz plot:
matlab2tikz(fileName, 'height', '\figureheight', 'width', '\figurewidth');

end
