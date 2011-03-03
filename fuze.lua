Version = "1.0.2.114"

maxiter     = 5
step        = 0.05

p           = print
fastfuze    = true

function fgain()
    set_behavior_clash_importance(1)
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = get_score(true)
            if fastfuze then
                do_global_wiggle_all(1)
            elseif iter < maxiter then
                do_global_wiggle_all(iter)
            end
            local s2_f = get_score(true)
        until s2_f - s1_f < step
        local s3_f = get_score(true)
        do_shake(1)
        local s4_f = get_score(true)
    until s4_f - s3_f < step
end

function fstruct(g, cl)
    set_behavior_clash_importance(cl)
    if g == "s" then
        do_shake(1)
    elseif g == "w" then
        do_global_wiggle_all(1)
    end
end

function floss(option, cl1, cl2)
    p("Fuzing Method ", option)
    p("cl1 ", cl1, ", cl2 ", cl2)
    if option == 1 then
        p("Pink Fuse cl1-s-cl2-wa")
        fstruct("s", cl1)
        fstruct("w", cl2)
    elseif option == 2 then
        p("Pink Fuse cl1-wa-cl=1-wa-cl2-wa")
        fstruct("w", cl1)
        fstruct("w", 1)
        fstruct("w", cl2)
    elseif option == 3 then
        p("cl1-s; cl2-s;")
        fstruct("s", cl1)
        fgain()
        fstruct("s", cl2)
    elseif option == 4 then
        p("cl1-wa[-cl2-wa]")
        fstruct("w", cl1)
        fstruct("w", cl2)
    elseif option == 5 then
        p("qStab cl1-s-cl2-wa-cl=1-s")
        fstruct("s", cl1)
        fstruct("w", cl2)
        fstruct("s", 1)
    end
end

function s_fuze(option, cl1, cl2)
    local s1_f = get_score(true)
    floss(option, cl1, cl2)
    fgain()
    local s2_f = get_score(true)
    if s2_f > s1_f then
        reset_recent_best()
        p("+", s2_f - s1_f, "+")
    end
    restore_recent_best()
end

    select_all()
    reset_recent_best()
    s_fuze(1, 0.1, 0.7)
    s_fuze(1, 0.3, 0.6)
    s_fuze(2, 0.5, 0.7)
    s_fuze(2, 0.7, 0.5)
    s_fuze(3, 0.05, 0.07)
    s_fuze(4, 0.3, 0.3)
    s_fuze(5, 0.1, 0.4)