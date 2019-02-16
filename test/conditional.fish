@mesg $current_filename

if true
    @test "true" $status -eq 0
end
if false
    @test "never runs" $status -eq 1
end
