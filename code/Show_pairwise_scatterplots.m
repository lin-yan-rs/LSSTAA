function Show_pairwise_scatterplots(data, doys, image_controls, dCoefs_all_a, dCoefs_all_b, doy_diff_threshold, temporal_diff_map, ntie_threshold, b_show_only_PIF, figure_id)
    n_img = length(doys);
    font_size = 10;
    for idx1 = 1:n_img-1
        if image_controls(idx1) == -1
            continue;
        end
        doy1 = doys(idx1);
        data1_org = data(:,:,idx1);
        for idx2 = idx1+1:n_img
            if image_controls(idx2) == -1
                continue;
            end
            doy2 = doys(idx2);
            if abs(doy1 - doy2) > doy_diff_threshold
                continue;
            end
            data2_org = data(:,:,idx2);
    
            % get valid tie points
            mask = data1_org ~= 0 & data2_org ~= 0 & temporal_diff_map>0;
            % data1_ = data1_org(mask);
            data2_ = data2_org(mask);
            if length(data2_) < ntie_threshold
                continue;
            end
           
            if b_show_only_PIF == false
                data1_vis = data1_org(data1_org ~= 0 & data2_org ~= 0);
                data2_vis = data2_org(data1_org ~= 0 & data2_org ~= 0);
            else
                data1_vis = data1_org(data1_org ~= 0 & data2_org ~= 0 & temporal_diff_map>0);
                data2_vis = data2_org(data1_org ~= 0 & data2_org ~= 0 & temporal_diff_map>0);
            end
    
            ntie_vis = length(data1_vis);
            rsp_disp = ceil(ntie_vis/1000);
            data1_vis = data1_vis(1:rsp_disp:ntie_vis);
            data2_vis = data2_vis(1:rsp_disp:ntie_vis);
   
            data1_vis = data1_vis*dCoefs_all_a(idx1) + dCoefs_all_b(idx1);
            data2_vis = data2_vis*dCoefs_all_a(idx2) + dCoefs_all_b(idx2);
            value_min = min(quantile(data1_vis, 0.005), quantile(data2_vis, 0.005));
            value_max = max(quantile(data1_vis, 0.995), quantile(data2_vis, 0.995));
 
            figure(figure_id);
            plt = subplot(n_img-1,n_img-1,(n_img-1)*(idx1-1) + idx2-1); hold off;
            dscatter(double(data1_vis),double(data2_vis),'log',1);axis equal;axis([value_min value_max value_min value_max]);
            line([value_min value_max], [value_min value_max], 'color',[0.5 0.5 0.5], 'linewidth', 1);
            set(gca,'fontsize',font_size); set(gcf,'Color',[1,1, 1]); box(plt,'off'); shading flat; shading interp; set(gcf,'Color',[1,1, 1]);
            set(gca,'XTick',[], 'YTick', [])
            set(gca,'FontWeight','bold');
    
            xlabel(doys(idx1), 'color', 'r');
            ylabel(doys(idx2), 'color', 'r');
        end
    end
end