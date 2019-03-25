function GenerateSUMOFLUXfigures()

disp('*******************************************************************')
disp('SUMOFLUX plot figures')
disp('    1: All figures')
disp('    2: Figure 2')
disp('    3: Figure 3 and Supplementary Figure 6')
disp('    4: Figure 4 and Supplementary Figure 7')
disp('    5: Figure 5')
disp('    6: Supplementary Figure 2')
disp('    7: Supplementary Figure 3')
disp('    8: Supplementary Figure 4')
disp('    9: Supplementary Figure 5')

repeat = 1;

while repeat
    plotNumber = input('Specify SUMOFLUX figure to plot (type 1, 2, 3, 4, 5, 6, 7, 8, 9) [exit]  >>');
    if isempty(plotNumber)
        clear all
        disp('No figure chosen. SUMOFLUX terminated')
        return;
    else
        if plotNumber <0 || plotNumber >9
            disp('***input error, try again***');
            continue;
        end
    end
    switch plotNumber
        case 0
            clear all
            return
        case 1 
            clear all
            plot_fig2;
            clear all;     
            plot_fig3figS6;
            clear all;
            plot_fig4_figS7;
            clear all
            plot_fig5;
            clear all
            plot_figS2;
            clear all
            plot_figS3;
            clear all
            plot_figS4;
            clear all
            plot_figS5;
            repeat = 0;
        case 2  
            clear all;
            plot_fig2;
            repeat = 1;
        case 3
            clear all;     
            plot_fig3figS6;
            repeat = 1;
        case 4
            clear all;
            plot_fig4_figS7;
            repeat = 1;
        case 5
            clear all
            plot_fig5;
            repeat = 1;
        case 6
            clear all
            plot_figS2;
            repeat = 1;
        case 7
            clear all
            plot_figS3;
            repeat = 1;
        case 8
            clear all
            plot_figS4;
            repeat = 1;
        case 9
            clear all
            plot_figS5;
            repeat = 1;
    end
end
clear all
